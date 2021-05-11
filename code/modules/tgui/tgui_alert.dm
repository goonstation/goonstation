/*
 * Copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * Licensed under MIT to Goonstation only (https://choosealicense.com/licenses/mit/)
 */

/**
 * Creates a TGUI alert window and returns the user's response.
 *
 * This proc should be used to create alerts that the caller will wait for a response from.
 * Arguments:
 * * user - The user to show the alert to.
 * * message - The content of the alert, shown in the body of the TGUI window.
 * * title - The of the alert modal, shown on the top of the TGUI window.
 * * buttons - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * timeout - The timeout of the alert, after which the modal will close and qdel itself. Disabled by default, can be set otherwise.
 */
/proc/tgui_alert(mob/user, message = null, title = null, list/buttons = list("Ok"), timeout = 0 SECONDS)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_modal/alert = new(user, message, title, buttons, timeout)
	alert.ui_interact(user)
	UNTIL(alert.choice || alert.closed)
	if (alert)
		. = alert.choice
		qdel(alert)

/**
 * Creates an asynchronous TGUI alert window with an associated callback.
 *
 * This proc should be used to create alerts that invoke a callback with the user's chosen option.
 * Arguments:
 * * user - The user to show the alert to.
 * * message - The content of the alert, shown in the body of the TGUI window.
 * * title - The of the alert modal, shown on the top of the TGUI window.
 * * buttons - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the alert, after which the modal will close and qdel itself. Disabled by default, can be set otherwise.
 */
/proc/tgui_alert_async(mob/user, message = null, title = null, list/buttons = list("Ok"), datum/callback/callback, timeout = 0 SECONDS)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_modal/async/alert = new(user, message, title, buttons, callback, timeout)
	alert.ui_interact(user)

/**
 * # tgui_modal
 *
 * Datum used for instantiating and using a TGUI-controlled modal that prompts the user with
 * a message and has buttons for responses.
 */
/datum/tgui_modal
	/// The title of the TGUI window
	var/title
	/// The textual body of the TGUI window
	var/message
	/// The list of buttons (responses) provided on the TGUI window
	var/list/buttons
	/// The button that the user has pressed, null if no selection has been made
	var/choice
	/// The time at which the tgui_modal was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_modal, after which the window will close and delete itself.
	var/timeout
	/// Boolean field describing if the tgui_modal was closed by the user.
	var/closed

/datum/tgui_modal/New(mob/user, message, title, list/buttons, timeout, copyButtons = TRUE)
	src.title = title
	src.message = message
	if (copyButtons)
		src.buttons = buttons.Copy()
	if (timeout)
		src.timeout = timeout
		src.start_time = TIME
		SPAWN_DBG(timeout)
			qdel(src)
	. = ..()

/datum/tgui_modal/disposing()
	tgui_process.close_uis(src)
	qdel(buttons)
	buttons = null
	. = ..()

/datum/tgui_modal/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AlertModal")
		ui.open()

/datum/tgui_modal/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_modal/ui_state(mob/user)
	. = tgui_always_state

/datum/tgui_modal/ui_data(mob/user)
	if(timeout)
		. = list()
		.["timeout"] = clamp(((timeout - (TIME - start_time) - 1 SECONDS) / (timeout - 1 SECONDS)), 0, 1)

/datum/tgui_modal/ui_static_data(mob/user)
	. = list(
		"title" = title,
		"message" = message,
		"buttons" = buttons
	)

/datum/tgui_modal/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("choose")
			if (!(params["choice"] in buttons))
				return
			choice = params["choice"]
			tgui_process.close_uis(src)
			. = TRUE

/**
 * # async tgui_modal
 *
 * An asynchronous version of tgui_modal to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_modal/async
	/// The callback to be invoked by the tgui_modal upon having a choice made.
	var/datum/callback/callback

/datum/tgui_modal/async/New(mob/user, message, title, list/buttons, callback, timeout)
	..(user, title, message, buttons, timeout)
	src.callback = callback

/datum/tgui_modal/async/disposing(force, ...)
	qdel(callback)
	callback = null
	. = ..()

/datum/tgui_modal/async/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/tgui_modal/async/ui_act(action, list/params)
	. = ..()
	if (!. || choice == null)
		return
	callback.InvokeAsync(choice)
	qdel(src)
