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
 * * items - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * timeout - The timeout of the alert, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * autofocus - The bool that controls if this alert should grab window focus. - BROKEN DON'T SET TO FALSE (nulls items, ask zewaka)
 * * content_window - The name of the part to be used for the alert's content, to be used in lieu of message
 * * do_wait - waits for user input then returns it. Set to false for asynchronism
 * * theme - The TGUI theme used for the window.
 * * cant_interact - A number of seconds that the user must wait before being able to interact or close the alert. None by default.
 */
/proc/tgui_alert(
		mob/user,
		message = "",
		title,
		list/items = list("Ok"),
		timeout = 0,
		autofocus = TRUE,
		content_window = null,
		do_wait = TRUE,
		theme = null,
		cant_interact = 0
)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	if (!user?.client) // No NPCs or they hang Mob AI process
		return
	if(!length(items))
		log_tgui(user, "Error: TGUI Alert called with no items.", "TguiAlert")
		return
	// A gentle nudge - you should not be using TGUI alert for anything other than a simple message.
	if(length(items) > 3)
		log_tgui(user, "Error: TGUI Alert initiated with too many items. Use a list.", "TguiAlert")
		return tgui_input_list(user, message, title, items, timeout, autofocus)
	var/datum/tgui_modal/alert = new(user, message, title, items, timeout, autofocus, content_window, theme, cant_interact)
	alert.ui_interact(user)
	if (!do_wait)
		return
	alert.wait()
	if (alert)
		. = alert.choice
		qdel(alert)

/**
 * # tgui_modal
 *
 * Datum used for instantiating and using a TGUI-controlled modal that prompts the user with
 * a message and has items for responses.
 */
/datum/tgui_modal
	/// The title of the TGUI window
	var/title
	/// The textual body of the TGUI window
	var/message
	/// The list of items (responses) provided on the TGUI window
	var/list/items
	/// The button that the user has pressed, null if no selection has been made
	var/choice
	/// The time at which the tgui_modal was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_modal, after which the window will close and delete itself.
	var/timeout
	/// The bool that controls if this modal should grab window focus
	var/autofocus
	/// Boolean field describing if the tgui_modal was closed by the user.
	var/closed
	/// The name of the part to be used for the alert's content, to be used in lieu of message
	var/content_window
	/// The TGUI theme used for the window
	var/theme
	/// A number of seconds that the user must wait before being able to interact or close the alert.
	var/cant_interact

/datum/tgui_modal/New(mob/user, message, title, list/items, timeout, autofocus, content_window, theme, cant_interact)
	src.autofocus = autofocus
	src.items = items.Copy()
	src.title = title
	src.message = message
	src.content_window = content_window
	src.theme = theme
	src.start_time = TIME
	src.cant_interact = cant_interact
	if (timeout)
		src.timeout = timeout
		SPAWN(timeout)
			qdel(src)
	. = ..()

/datum/tgui_modal/disposing()
	tgui_process.close_uis(src)
	qdel(items)
	items = null
	. = ..()

/**
 * Waits for a user's response to the tgui_alert's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_modal/proc/wait()
	UNTIL(choice || closed || QDELETED(src))

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
	. = list()
	if (timeout)
		.["timeout"] = clamp(((timeout - (TIME - start_time) - 1 SECONDS) / (timeout - 1 SECONDS)), 0, 1)
	// |GOONSTATION-ADD|
	if (cant_interact)
		.["cant_interact"] = clamp(((cant_interact - (TIME - start_time)) / cant_interact), 0, 1)
		.["cant_interact_value"] = cant_interact

/datum/tgui_modal/ui_static_data(mob/user)
	. = list(
		"title" = title,
		"message" = message,
		"items" = items,
		"autofocus" = autofocus,
		// |GOONSTATION-ADD| all below
		"content_window" = content_window,
		"theme" = theme,
		"cdn" = cdn,
	)

/datum/tgui_modal/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("choose")
			if (!(params["choice"] in items))
				log_tgui(usr, "<b>TGUI/ZeWaka</b>: [usr] entered a non-existent button choice: [params["choice"]]")
				return
			set_choice(params["choice"])
			closed = TRUE
			tgui_process.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			choice = params["choice"]
			tgui_process.close_uis(src)
			. = TRUE

/datum/tgui_modal/proc/set_choice(choice)
	src.choice = choice
