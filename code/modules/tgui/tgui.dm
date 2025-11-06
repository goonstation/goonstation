/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui datum (represents a UI).
 */
/datum/tgui
	/// The mob who opened/is using the UI.
	var/mob/user
	/// The object which owns the UI.
	var/datum/src_object
	/// The title of the UI.
	var/title
	/// The window_id for browse() and onclose().
	var/datum/tgui_window/window
	/// Key that is used for remembering the window geometry.
	var/window_key
	/// Deprecated: Window size.
	var/window_size
	/// The interface (template) to be used for this UI.
	var/interface
	/// Update the UI every MC tick.
	var/autoupdate = TRUE
	/// If the UI has been initialized yet.
	var/initialized = FALSE
	/// Time of opening the window.
	var/opened_at
	/// Stops further updates when close() was called.
	var/closing = FALSE
	/// The status/visibility of the UI.
	var/status = UI_INTERACTIVE
	/// Timed refreshing state
	var/refreshing = FALSE
	/// Topic state used to determine status/interactability.
	var/datum/ui_state/state = null
	/// Rate limit client refreshes to prevent DoS.
	var/list/cooldowns // |GOONSTATION-CHANGE| Different cooldown method
	/// Are byond mouse events beyond the window passed in to the ui
	var/mouse_hooked = FALSE // |GOONSTATION-ADD| Was removed upstream in https://github.com/tgstation/tgstation/pull/90310

/**
 * public
 *
 * Create a new UI.
 *
 * required user mob The mob who opened/is using the UI.
 * required src_object datum The object or datum which owns the UI.
 * required interface string The interface used to render the UI.
 * optional title string The title of the UI.
 *
 * return datum/tgui The requested UI.
 */
/datum/tgui/New(mob/user, datum/src_object, interface, title)
	..()
	log_tgui(user,
		"new [interface] fancy [user?.client?.preferences.tgui_fancy]",
		src_object = src_object) // |GOONSTATION-CHANGE| (client.preferences)
	src.user = user
	src.src_object = src_object
	src.window_key = "\ref[src_object]-main" // |GOONSTATION-CHANGE| (REF->\ref)
	src.interface = interface
	if(title)
		src.title = title
	src.state = src_object.ui_state()

/datum/tgui/disposing() // |GOONSTATION-CHANGE| Destroy -> disposing
	user = null
	src_object = null
	. = ..()

/**
 * public
 *
 * Open this UI (and initialize it with data).
 *
 * return bool - TRUE if a new pooled window is opened, FALSE in all other situations including if a new pooled window didn't open because one already exists.
 */
/datum/tgui/proc/open()
	if(!user?.client) // |GOONSTATION-CHANGE| Handle null user check
		return FALSE
	if(window)
		return FALSE
	process_status()
	if(status < UI_UPDATE)
		return FALSE
	window = tgui_process.request_pooled_window(user, interface) // |GOONSTATION-CHANGE| Different process holder, add interface
	if(!window)
		// |GOONSTATION-ADD|
		if(istype(src_object, /datum/tgui_modal))
			qdel(src_object)
		return FALSE
	opened_at = world.time
	window.acquire_lock(src)
	if(!window.is_ready())
		window.initialize(
			strict_mode = TRUE,
			fancy = user.client.preferences.tgui_fancy, // |GOONSTATION-CHANGE| Different preference method
			assets = list(
				get_assets(/datum/asset/group/base_tgui), // |GOONSTATION-CHANGE| Different asset method
			))
	else
		window.send_message("ping")
	// |GOONSTATION-CHANGE| Different asset method
	for(var/datum/asset/asset in src_object.ui_assets(user))
		send_asset(asset)
	window.send_message("update", get_payload(
		with_data = TRUE,
		with_static_data = TRUE))
	// |GOONSTATION-ADD| Was removed upstream in https://github.com/tgstation/tgstation/pull/90310
	if(mouse_hooked)
		window.set_mouse_macro()
	tgui_process.on_open(src) // |GOONSTATION-CHANGE| Different process holder
	SEND_SIGNAL(user, COMSIG_TGUI_WINDOW_OPEN, src) // |GOONSTATION-ADD| Send signal
	return TRUE

// |GOONSTATION-CHANGE| Asset caching/sending done differently
/datum/tgui/proc/send_assets()
	PRIVATE_PROC(TRUE)
	for(var/datum/asset/asset in src_object.ui_assets(user))
		send_asset(asset)

/**
 * public
 *
 * Close the UI.
 *
 * optional can_be_suspended bool
 */
/datum/tgui/proc/close(can_be_suspended = TRUE)
	if(closing)
		return
	closing = TRUE
	// |GOONSTATION-ADD| Close observers' UIs
	for(var/mob/dead/target_observer/ghost in src.user.observers)
		for(var/datum/tgui/ghost_win in ghost.tgui_open_uis)
			if(ghost_win.src_object == src.src_object)
				ghost_win.close()
	// If we don't have window_id, open proc did not have the opportunity
	// to finish, therefore it's safe to skip this whole block.
	if(window)
		// Windows you want to keep are usually blue screens of death
		// and we want to keep them around, to allow user to read
		// the error message properly.
		window.release_lock()
		window.close(can_be_suspended)
		src_object.ui_close(user)
		tgui_process.on_close(src) // |GOONSTATION-CHANGE| Different process holder
	state = null
	qdel(src)

/**
 * public
 *
 * Enable/disable auto-updating of the UI.
 *
 * required value bool Enable/disable auto-updating.
 */
/datum/tgui/proc/set_autoupdate(autoupdate)
	src.autoupdate = autoupdate

// |GOONSTATION-ADD| Was removed upstream in https://github.com/tgstation/tgstation/pull/90310
/**
 * public
 *
 * Enable/disable passing through byond mouse events to the window
 *
 * required value bool Enable/disable hooking.
 */
/datum/tgui/proc/set_mouse_hook(value)
	src.mouse_hooked = value
	//Handle unhooking/hooking on already open windows ?

/**
 * public
 *
 * Replace current ui.state with a new one.
 *
 * required state datum/ui_state/state Next state
 */
/datum/tgui/proc/set_state(datum/ui_state/state)
	src.state = state

/**
 * public
 *
 * Makes an asset available to use in tgui.
 *
 * required asset datum/asset
 *
 * return bool - true if an asset was actually sent
 */
/datum/tgui/proc/send_asset(datum/asset/asset)
	if(!window)
		CRASH("send_asset() was called either without calling open() first or when open() did not return TRUE.")
	return window.send_asset(asset)

/**
 * public
 *
 * Send a full update to the client (includes static data).
 *
 * optional custom_data list Custom data to send instead of ui_data.
 * optional force bool Send an update even if UI is not interactive.
 */
/datum/tgui/proc/send_full_update(custom_data, force)
	if(!user?.client || !initialized || closing) // |GOONSTATION-CHANGE| Handle null user check
		return
	// |GOONSTATION-CHANGE| Different cooldown method
	if(ON_COOLDOWN(src, "TGUI_REFRESH_COOLDOWN", TGUI_REFRESH_FULL_UPDATE_COOLDOWN))
		refreshing = TRUE
		SPAWN(GET_COOLDOWN(src, "TGUI_REFRESH_COOLDOWN"))
			src.send_full_update(custom_data, force)
		return
	refreshing = FALSE
	var/should_update_data = force || status >= UI_UPDATE
	window.send_message("update", get_payload(
		custom_data,
		with_data = should_update_data,
		with_static_data = TRUE))

/**
 * public
 *
 * Send a partial update to the client (excludes static data).
 *
 * optional custom_data list Custom data to send instead of ui_data.
 * optional force bool Send an update even if UI is not interactive.
 */
/datum/tgui/proc/send_update(custom_data, force)
	if(!user.client || !initialized || closing)
		return
	var/should_update_data = force || status >= UI_UPDATE
	window.send_message("update", get_payload(
		custom_data,
		with_data = should_update_data))

/**
 * private
 *
 * Package the data to send to the UI, as JSON.
 *
 * return list
 */
/datum/tgui/proc/get_payload(custom_data, with_data, with_static_data)
	var/list/json_data = list()
	json_data["config"] = list(
		"title" = title,
		"status" = status,
		"interface" = list(
			"name" = interface,
			// |GOONSTATION-CHANGE| Unsure what "layout" equivalent in Goonstation, if any, is, so commenting out for now
			// "layout" = user.client.prefs.read_preference(src_object.layout_prefs_used),
		),
		"refreshing" = refreshing,
		"window" = list(
			"key" = window_key,
			"size" = window_size,
			"fancy" = user.client.preferences.tgui_fancy,
			"locked" = user.client.preferences.tgui_lock,
			"mode" = user.client.darkmode ? "dark" : "light", // |GOONSTATION-ADD|
		),
		"client" = list(
			"ckey" = user.client.ckey,
			"address" = user.client.address,
			"computer_id" = user.client.computer_id,
		),
		"user" = list(
			"name" = "[user]",
			"observer" = isobserver(user),
		),
	)
	var/data = custom_data || with_data && src_object.ui_data(user)
	if(data)
		json_data["data"] = data
	var/static_data = with_static_data && src_object.ui_static_data(user)
	if(static_data)
		json_data["static_data"] = static_data
	if(src_object.tgui_shared_states)
		json_data["shared"] = src_object.tgui_shared_states
	return json_data

/**
 * private
 *
 * Run an update cycle for this UI. Called internally by tgui_process
 * every second or so.
 */
/datum/tgui/proc/process(force = FALSE) // /process doesn't exist on datums here |GOONSTATION-ADD|
	if(closing)
		return
	var/datum/host = src_object.ui_host(user)
	// If the object or user died (or something else), abort.
	if(!src_object || !host || !user || !window) // |GOONSTATION-CHANGE| Upstream using QDELETED, should we?
		close(can_be_suspended = FALSE)
		return
	// Validate ping
	if(!initialized && world.time - opened_at > TGUI_PING_TIMEOUT)
		log_tgui(user, "Error: Zombie window detected, closing.",
			window = window,
			src_object = src_object)
		close(can_be_suspended = FALSE)
		return
	// Update through a normal call to ui_interact
	if(status != UI_DISABLED && (autoupdate || force))
		src_object.ui_interact(user, src)
		return
	// Update status only
	var/needs_update = process_status()
	if(status <= UI_CLOSE)
		close()
		return
	if(needs_update)
		window.send_message("update", get_payload())

/**
 * private
 *
 * Updates the status, and returns TRUE if status has changed.
 */
/datum/tgui/proc/process_status()
	var/prev_status = status
	status = src_object.ui_status(user, state)
	// |GOONSTATION-ADD| Admins can have a little ghost interaction, as a treat
	if(user.client?.holder?.ghost_interaction)
		status = max(status, UI_INTERACTIVE)
	return prev_status != status

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui/proc/on_message(type, list/payload, list/href_list)
	// Pass act type messages to ui_act
	if(type && copytext(type, 1, 5) == "act/")
		var/act_type = copytext(type, 5)
		if(act_type != "play_note") // |GOONSTATION-ADD| Avoid music spamming logs
			log_tgui(user, "Action: [act_type] [href_list["payload"]]",
				window = window,
				src_object = src_object)
		process_status()
		// |GOONSTATION-CHANGE| Different queue method
		SPAWN(0)
			on_act_message(act_type, payload, state)
		return FALSE
	switch(type)
		if("ready")
			// Send a full update when the user manually refreshes the UI
			if(initialized)
				send_full_update()
			initialized = TRUE
		if("ping/reply")
			initialized = TRUE
		if("suspend")
			close(can_be_suspended = TRUE)
		if("close")
			close(can_be_suspended = FALSE)
		if("log")
			if(href_list["fatal"])
				close(can_be_suspended = FALSE)
		if("setSharedState")
			if(status != UI_INTERACTIVE)
				return
			LAZYLISTINIT(src_object.tgui_shared_states) // |GOONSTATION-CHANGE| LAZYINITLIST -> LAZYLISTINIT
			src_object.tgui_shared_states[href_list["key"]] = href_list["value"]
			tgui_process.update_uis(src_object) // |GOONSTATION_CHANGE| Different process holder

/// Wrapper for behavior to potentially wait until the next tick if the server is overloaded
/datum/tgui/proc/on_act_message(act_type, payload, state)
	if(QDELETED(src) || QDELETED(src_object))
		return
	if(src_object.ui_act(act_type, payload, src, state))
		tgui_process.update_uis(src_object) // |GOONSTATION-CHANGE| Different process holder
