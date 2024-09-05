/*
 * Copyright 2024 ZeWaka (https://github.com/ZeWaka)
 * Licensed under MIT (https://choosealicense.com/licenses/mit/)
 */

/**
 * Creates a TGUI window with a PIN input. Returns the user's response as string | null.
 *
 * This proc should be used to create windows for PIN entry that the caller will wait for a response from.
 * If tgui fancy chat is turned off: Will return a normal input. If a max or min value is specified, will
 * validate the input inside the UI and ui_act.
 *
 * Arguments:
 * * user - The user to show the numbox to.
 * * message - The content of the numbox, shown in the body of the TGUI window.
 * * title - The title of the numbox modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder. Users can press refresh with this.
 * * max_value - Specifies a maximum value. If none is set, it defaults to 9999.
 * * min_value - Specifies a minimum value. If none is set, it defaults to 0000.
 * * timeout - The timeout of the numbox, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * theme - The TGUI theme used for the window.
 */
/proc/tgui_input_pin(mob/user, message, title = "PIN Input", default, max_value = null, min_value = null, timeout = 0, theme = null)
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
	if (!isnull(default) && !isnum_safe(default))
		CRASH("TGUI input PIN prompt opened with non-null default PIN that is not a number.")
	if (!isnull(default) && (default > (!isnull(max_value) ? max_value : PIN_MAX) || default < (!isnull(min_value) ? min_value : PIN_MIN)))
		CRASH("TGUI input number prompt opened with a default number outside of the allowable range.")
	var/datum/tgui_input_pin/numbox = new(user, message, title, default, max_value, min_value, timeout, theme)
	numbox.ui_interact(user)
	numbox.wait()
	if (numbox)
		. = round(numbox.entry)
		if (max_value && (. > max_value))
			boutput(user, SPAN_ALERT("The number you entered is an invalid PIN (Maximum: [max_value])."))
			. = null
		else if (min_value && (. < min_value))
			boutput(user, SPAN_ALERT("The number you entered is an invalid PIN (Minimum: [min_value])."))
			. = null
		qdel(numbox)

/**
 * Creates an asynchronous TGUI PIN input window with an associated callback.
 *
 * This proc should be used to create windows for PIN entry that invoke a callback with the user's entry.
 *
 * Arguments:
 * * user - The user to show the numbox to.
 * * message - The content of the numbox, shown in the body of the TGUI window.
 * * title - The title of the numbox modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder. Users can press refresh with this.
 * * max_value - Specifies a maximum value. If none is set, it defaults to 9999.
 * * min_value - Specifies a minimum value. If none is set, it defaults to 0000.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the numbox, after which the modal will close and qdel itself. Disabled by default, can be set to seconds otherwise.
 * * theme - The TGUI theme used for the window.
 */
/proc/tgui_input_pin_async(mob/user, message, title = "PIN Input", default, max_value = null, min_value = null, datum/callback/callback, timeout = 60 SECONDS, theme = null)
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
	if (!isnull(default) && !isnum_safe(default))
		CRASH("TGUI input PIN prompt opened with default PIN that is not a number.")
	if (default > (!isnull(max_value) ? max_value : PIN_MAX) || default < min_value)
		CRASH("TGUI input number prompt opened with a default number outside of the allowable range.")
	var/datum/tgui_input_pin/async/numbox = new(user, message, title, default, max_value, min_value, callback, timeout, theme)
	numbox.ui_interact(user)

/**
 * # tgui_input_pin
 *
 * Datum used for instantiating and using a TGUI-controlled pin keyboard that prompts the user with
 * a message and has an input for pin entry.
 */
/datum/tgui_input_pin
	/// The user of the TGUI window
	var/mob/user
	/// Boolean field describing if the tgui_input_pin was closed by the user.
	var/closed
	/// The default (or current) value, shown as a default. Users can press reset with this.
	var/default
	/// The entry that the user has return_typed in.
	var/entry
	/// The maximum value that can be entered.
	var/max_value
	/// The minimum value that can be entered.
	var/min_value
	/// The prompt's body, if any, of the TGUI window.
	var/message
	/// The time at which the tgui_modal was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_input_pin, after which the window will close and delete itself.
	var/timeout
	/// The title of the TGUI window
	var/title
	/// The TGUI theme used for the window.
	var/theme


/datum/tgui_input_pin/New(mob/user, message, title, default, max_value = null, min_value = null, timeout, theme)
	src.user = user
	src.message = message
	src.title = title
	src.default = default
	src.max_value = max_value
	src.min_value = min_value
	src.theme = theme
	if (timeout)
		src.timeout = timeout
		src.start_time = TIME
		SPAWN(src.timeout)
			qdel(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_input_pin's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_input_pin/proc/wait()
	while (user.client && !src.entry && !src.closed && !QDELETED(src))
		sleep(1)

/datum/tgui_input_pin/disposing(force, ...)
	tgui_process.close_uis(src)
	. = ..()

/datum/tgui_input_pin/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PINInputModal")
		ui.open()

/datum/tgui_input_pin/ui_close(mob/user)
	. = ..()
	src.closed = TRUE

/datum/tgui_input_pin/ui_state(mob/user)
	return tgui_always_state

/datum/tgui_input_pin/ui_data(mob/user)
	. = list(
		"init_value" = src.default || null,
		"message" = src.message,
		"max_value" = src.max_value || PIN_MAX,
		"min_value" = src.min_value || PIN_MIN,
		"title" = src.title,
		"theme" = src.theme,
	)
	if(timeout)
		.["timeout"] = clamp(((src.timeout - (TIME - src.start_time) - 1 SECONDS) / (src.timeout - 1 SECONDS)), 0, 1)

/datum/tgui_input_pin/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			var/input_arr = params["entry"]
			// Convert the array[4] to a single number
			var/input_num = input_arr[1] * 1000 + input_arr[2] * 100 + input_arr[3] * 10 + input_arr[4] * 1
			if (src.max_value && (input_num > src.max_value))
				boutput(user, SPAN_ALERT("The number you entered is an invalid PIN (Maximum: [src.max_value])."))
				return FALSE
			if (src.min_value && (input_num < src.min_value))
				boutput(user, SPAN_ALERT("The number you entered is an invalid PIN (Minimum: [src.min_value])."))
				return FALSE
			src.set_entry(input_num)
			tgui_process.close_uis(src)
			return TRUE
		if("cancel")
			src.set_entry(null)
			tgui_process.close_uis(src)
			return TRUE

/datum/tgui_input_pin/proc/set_entry(entry)
	src.entry = entry

/**
 * # async tgui_input_pin
 *
 * An asynchronous version of tgui_input_pin to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_input_pin/async
	/// The callback to be invoked by the tgui_input_pin upon having a choice made.
	var/datum/callback/callback

/datum/tgui_input_pin/async/New(mob/user, message, title, default, max_value = null, min_value = null, callback, timeout, theme)
	. = ..()
	src.callback = callback

/datum/tgui_input_pin/async/disposing(force, ...)
	qdel(src.callback)
	src.callback = null
	. = ..()

/datum/tgui_input_pin/async/set_entry(entry)
	. = ..()
	if(!isnull(src.entry))
		src.entry = round(src.entry)
		if (src.max_value && (src.entry > src.max_value))
			boutput(user, SPAN_ALERT("The number you entered is an invalid PIN (Maximum: [src.max_value])."))
			return
		if (src.min_value && (src.entry < src.min_value))
			boutput(user, SPAN_ALERT("The number you entered is an invalid PIN (Minimum: [src.min_value])."))
			return
		callback?.InvokeAsync(src.entry)

/datum/tgui_input_pin/async/wait()
	return
