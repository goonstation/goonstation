/*
 * Copyright 2021 jlsnow301 (https://github.com/jlsnow301)
 * Licensed under MIT (https://choosealicense.com/licenses/mit/)
 */

/**
 * Creates a TGUI window with a text input. Returns the user's response.
 *
 * This proc should be used to create windows for text entry that the caller will wait for a response from.
 * If tgui fancy chat is turned off: Will return a normal input. If max_length is specified, will return
 * stripped_multiline_input.
 *
 * Arguments:
 * * user - The user to show the textbox to.
 * * message - The content of the textbox, shown in the body of the TGUI window.
 * * title - The title of the textbox modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder.
 * * max_length - Specifies a max length for input.
 * * multiline -  Bool that determines if the input box is much larger. Good for large messages, laws, etc.
 * * timeout - The timeout of the textbox, after which the modal will close and qdel itself. Set to zero for no timeout.
 */
/proc/tgui_input_text(mob/user, message = null, title = "Text Input", default = null, max_length = null, multiline = FALSE, timeout = 0, allowEmpty = FALSE)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	if (!user.client) // No NPCs or they hang Mob AI process
		return
	var/datum/tgui_input_text/textbox = new(user, message, title, default, max_length, multiline, timeout, allowEmpty)
	textbox.ui_interact(user)
	textbox.wait()
	if (textbox)
		. = textbox.entry
		qdel(textbox)

/**
 * Creates an asynchronous TGUI text input window with an associated callback.
 *
 * This proc should be used to create textboxes that invoke a callback with the user's entry.
 * Arguments:
 * * user - The user to show the textbox to.
 * * message - The content of the textbox, shown in the body of the TGUI window.
 * * title - The title of the textbox modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder.
 * * max_length - Specifies a max length for input.
 * * multiline -  Bool that determines if the input box is much larger. Good for large messages, laws, etc.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the textbox, after which the modal will close and qdel itself. Disabled by default, can be set to seconds otherwise.
 */
/proc/tgui_input_text_async(mob/user, message = null, title = "Text Input", default = null, max_length = null, multiline = FALSE, datum/callback/callback, timeout = 0, allowEmpty = FALSE)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	if (!user.client) // No NPCs or they hang Mob AI process
		return
	if (max_length && length(message) > max_length)
		CRASH("TGUI input text window opened with a message greater than the max length.")
	var/datum/tgui_input_text/async/textbox = new(user, message, title, default, max_length, multiline, callback, timeout, allowEmpty)
	textbox.ui_interact(user)

/**
 * # tgui_input_text
 *
 * Datum used for instantiating and using a TGUI-controlled textbox that prompts the user with
 * a message and has an input for text entry.
 */
/datum/tgui_input_text
	/// The user of the TGUI window
	var/mob/user
	/// Boolean field describing if the tgui_input_text was closed by the user.
	var/closed
	/// The default (or current) value, shown as a default.
	var/default
	/// The entry that the user has return_typed in.
	var/entry
	/// The maximum length for text entry
	var/max_length
	/// The prompt's body, if any, of the TGUI window.
	var/message
	/// Multiline input for larger input boxes.
	var/multiline
	/// The time at which the tgui_modal was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_input_text, after which the window will close and delete itself.
	var/timeout
	/// The title of the TGUI window
	var/title
	/// Makes the text box allow an empty string to be submitted
	var/allowEmpty


/datum/tgui_input_text/New(mob/user, message, title, default, max_length, multiline, timeout, allowEmpty)
	src.user = user
	src.default = default
	src.max_length = max_length
	src.message = message
	src.multiline = multiline
	src.title = title
	src.allowEmpty = allowEmpty
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		SPAWN(timeout)
			qdel(src)
	. = ..()

/datum/tgui_input_text/disposing(force, ...)
	tgui_process.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_input_text's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_input_text/proc/wait()
	while (user.client && !entry && !closed && !QDELETED(src))
		sleep(1)

/datum/tgui_input_text/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TextInputModal")
		ui.open()

/datum/tgui_input_text/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_input_text/ui_state(mob/user)
	return tgui_always_state

/datum/tgui_input_text/ui_static_data(mob/user)
	. = list(
		"max_length" = max_length,
		"message" = message,
		"multiline" = multiline,
		"placeholder" = default, /// You cannot use default as a const
		"title" = title,
		"allowEmpty" = allowEmpty,
	)

/datum/tgui_input_text/ui_data(mob/user)
	. = list("timeout" = null)

	if(timeout)
		.["timeout"] = clamp(((timeout - (TIME - start_time) - 1 SECONDS) / (timeout - 1 SECONDS)), 0, 1)

/datum/tgui_input_text/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			if(max_length && (length(params["entry"]) > max_length))
				return FALSE
			set_entry(params["entry"])
			tgui_process.close_uis(src)
			return TRUE
		if("cancel")
			set_entry(null)
			tgui_process.close_uis(src)
			return TRUE

/datum/tgui_input_text/proc/set_entry(entry)
		src.entry = entry

/**
 * # async tgui_input_text
 *
 * An asynchronous version of tgui_input_text to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_input_text/async
	/// The callback to be invoked by the tgui_input_text upon having a choice made.
	var/datum/callback/callback

/datum/tgui_input_text/async/New(mob/user, message, title, default, max_length, multiline, callback, timeout)
	..(user, message, title, default, max_length, multiline, timeout)
	src.callback = callback

/datum/tgui_input_text/async/disposing(force, ...)
	qdel(callback)
	callback = null
	. = ..()

/datum/tgui_input_text/async/set_entry(entry)
	. = ..()
	if(!isnull(src.entry))
		callback?.InvokeAsync(src.entry)

/datum/tgui_input_text/async/wait()
	return
