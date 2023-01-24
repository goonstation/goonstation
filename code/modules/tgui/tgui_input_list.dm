/*
 * Copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * Changes: watermelon914 (https://github.com/watermelon914)
 * Changes: jlsnow301 (https://github.com/jlsnow301)
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
 * * items - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * default - If an option is already preselected on the UI. Current values, etc.
 * * timeout - The timeout of the input box, after which the menu will close and qdel itself. Set to zero for no timeout.
 * * autofocus - The bool that controls if this alert should grab window focus.
 * * allowIllegal - Whether to allow illegal characters in items.
 * * start_with_search - Whether to start with the search bar open ("auto" for automatic, TRUE for yes, FALSE for no).
 */
/proc/tgui_input_list(mob/user, message, title = "Select", list/items, default, timeout = 0, autofocus = TRUE, allowIllegal = FALSE,
		start_with_search = "auto")
	if (!user)
		user = usr
	if(!length(items))
		return
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
	if (!user?.client) // No NPCs or they hang Mob AI process
		return
	var/datum/tgui_modal/list_input/input = new(user, message, title, items, default, timeout, autofocus, allowIllegal, start_with_search)
	input.ui_interact(user)
	UNTIL(!user.client || input.choice || input.closed)
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
 * * items - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * default - If an option is already preselected on the UI. Current values, etc.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the input box, after which the menu will close and qdel itself. Set to zero for no timeout.
 * * autofocus - The bool that controls if this alert should grab window focus.
 * * allowIllegal - Whether to allow illegal characters in items.
 * * start_with_search - Whether to start with the search bar open ("auto" for automatic, TRUE for yes, FALSE for no).
 */
/proc/tgui_input_list_async(mob/user, message, title = "Select", list/items, default, datum/callback/callback, timeout = 60 SECONDS, autofocus = TRUE,
		allowIllegal = FALSE, start_with_search = "auto")
	if (!user)
		user = usr
	if(!length(items))
		return
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_modal/list_input/async/input = new(user, message, title, items, default, callback, timeout, autofocus, allowIllegal, start_with_search)
	input.ui_interact(user)

/**
 * # tgui_modal/list_input
 *
 * Datum used for instantiating and using a TGUI-controlled list input that prompts the user with
 * a message and shows a list of selectable options
 */
/datum/tgui_modal/list_input
	/// Buttons (strings specifically) mapped to the actual value (e.g. a mob or a verb)
	var/list/items_map
	/// The default button to be selected
	var/default
	/// Whether we start with the search bar open
	var/start_with_search

/datum/tgui_modal/list_input/New(mob/user, message, title, list/items, default, timeout, autofocus = TRUE, allowIllegal = FALSE,
		start_with_search = "auto")
	. = ..(user, message, title, items, timeout, autofocus)
	src.items = list()
	src.items_map = list()
	src.default = default
	src.start_with_search = start_with_search == "auto" ? length(items) > 10 : start_with_search

	// Gets rid of illegal characters
	var/static/regex/whitelistedWords = regex(@{"([^\u0020-\u8000]+)"})

	for(var/i in items)
		var/string_key = allowIllegal ? i : whitelistedWords.Replace("[i]", "")

		src.items += string_key
		src.items_map[string_key] = i

/datum/tgui_modal/list_input/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ListInputModal")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/tgui_modal/list_input/ui_static_data(mob/user)
	. = ..()
	.["init_value"] = default || items[1]
	.["start_with_search"] = start_with_search

/datum/tgui_modal/list_input/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// We need to omit the parent call for this specifically, as the action parsing conflicts with parent.
	if(!ui || ui.status != UI_INTERACTIVE)
		return
	switch(action)
		if("submit")
			if (!(params["entry"] in items))
				return
			choice = items_map[params["entry"]]
			closed = TRUE
			tgui_process.close_uis(src)
			. = TRUE
		if("cancel")
			closed = TRUE
			tgui_process.close_uis(src)
			. = TRUE

/**
 * # async tgui_modal/list_input
 *
 * An asynchronous version of tgui_modal/list_input to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_modal/list_input/async
	/// The callback to be invoked by the tgui_modal/list_input upon having a choice made.
	var/datum/callback/callback

/datum/tgui_modal/list_input/async/New(mob/user, message, title, list/items, default, callback, timeout, autofocus = TRUE, allowIllegal = FALSE)
	..(user, message, title, items, default, timeout, autofocus, allowIllegal)
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
