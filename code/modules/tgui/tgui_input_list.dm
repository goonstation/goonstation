/*
 * Copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * Changes: watermelon914 (https://github.com/watermelon914)
 * Licensed under MIT to Goonstation only (https://choosealicense.com/licenses/mit/)
 */

/**
 * Creates a TGUI input list window and returns the user's response.
 *
 * This proc should be used to create alerts that the caller will wait for a response from.
 * Arguments:
 * * user - The user to show the input box to.
 * * message - The content of the input box, shown in the body of the TGUI window.
 * * title - The title of the input box, shown on the top of the TGUI window.
 * * buttons - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * timeout - The timeout of the input box, after which the input box will close and qdel itself. Set to zero for no timeout.
 */
/proc/tgui_input_list(mob/user, message, title, list/buttons, timeout = 0)
	if (!user)
		user = usr
	if(!length(buttons))
		return
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
	if (!user)
		return
	var/datum/tgui_modal/list_input/input = new(user, message, title, buttons, timeout)
	input.ui_interact(user)
	UNTIL(input.choice || input.closed)
	if (input)
		. = input.choice
		qdel(input)

/**
 * Creates an asynchronous TGUI input list window with an associated callback.
 *
 * This proc should be used to create inputs that invoke a callback with the user's chosen option.
 * Arguments:
 * * user - The user to show the input box to.
 * * message - The content of the input box, shown in the body of the TGUI window.
 * * title - The title of the input box, shown on the top of the TGUI window.
 * * buttons - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the input box, after which the menu will close and qdel itself. Set to zero for no timeout.
 */
/proc/tgui_input_list_async(mob/user, message, title, list/buttons, datum/callback/callback, timeout = 60 SECONDS)
	if (!user)
		user = usr
	if(!length(buttons))
		return
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_modal/list_input/async/input = new(user, message, title, buttons, callback, timeout)
	input.ui_interact(user)

/**
 * # tgui_modal/list_input
 *
 * Datum used for instantiating and using a TGUI-controlled list input that prompts the user with
 * a message and shows a list of selectable options
 */
/datum/tgui_modal/list_input
	/// Buttons (strings specifically) mapped to the actual value (e.g. a mob or a verb)
	var/list/buttons_map

/datum/tgui_modal/list_input/New(mob/user, message, title, list/buttons, timeout, copyButtons = FALSE)
	src.buttons = list()
	src.buttons_map = list()

	// Gets rid of illegal characters
	var/static/regex/whitelistedWords = regex(@{"([^\u0020-\u8000]+)"})

	for(var/i in buttons)
		var/string_key = whitelistedWords.Replace("[i]", "")

		src.buttons += string_key
		src.buttons_map[string_key] = i

	. = ..()


/datum/tgui_modal/list_input/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ListInput")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/tgui_modal/list_input/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// We need to omit the parent call for this specifically, as the action parsing conflicts with parent.
	if(!ui || ui.status != UI_INTERACTIVE)
		return
	switch(action)
		if("choose")
			if (!(params["choice"] in buttons))
				return
			choice = buttons_map[params["choice"]]
			tgui_process.close_uis(src)
			. = TRUE
		if("cancel")
			tgui_process.close_uis(src)
			closed = TRUE
			. = TRUE

/**
 * # async tgui_modal/list_input
 *
 * An asynchronous version of tgui_modal/list_input to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_modal/list_input/async
	/// The callback to be invoked by the tgui_modal/list_input upon having a choice made.
	var/datum/callback/callback

/datum/tgui_modal/list_input/async/New(mob/user, message, title, list/buttons, callback, timeout)
	..(user, title, message, buttons, timeout)
	src.callback = callback

/datum/tgui_modal/list_input/async/disposing(force, ...)
	qdel(callback)
	callback = null
	. = ..()

/datum/tgui_modal/list_input/async/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/tgui_modal/list_input/async/ui_act(action, list/params)
	. = ..()
	if (!. || choice == null)
		return
	callback.InvokeAsync(choice)
	qdel(src)
