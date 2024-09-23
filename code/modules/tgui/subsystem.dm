/*
 * tgui process
 *
 * Contains most of tgui state and process code. Rest is in tgui.dm for the process.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/// Open uis owned by this datum
/// Lazy, since this case is semi rare
/datum/var/list/datum/tgui/open_uis

/**
 * public
 *
 * Requests a usable tgui window from the pool.
 * Returns null if pool was exhausted.
 *
 * required user mob
 * return datum/tgui
 */
/datum/controller/process/tgui/proc/request_pooled_window(mob/user)
	if(!user.client)
		return null
	var/list/windows = user.client.tgui_windows
	var/window_id
	var/datum/tgui_window/window
	var/window_found = FALSE
	// Find a usable window
	for(var/i in 1 to TGUI_WINDOW_HARD_LIMIT)
		window_id = TGUI_WINDOW_ID(i)
		window = windows[window_id]
		// As we are looping, create missing window datums
		if(!window)
			window = new(user.client, window_id, pooled = TRUE)
		// Skip windows with acquired locks
		if(window.locked)
			continue
		if(window.status == TGUI_WINDOW_READY)
			return window
		if(window.status == TGUI_WINDOW_CLOSED)
			window.status = TGUI_WINDOW_LOADING
			window_found = TRUE
			break
	if(!window_found)
		log_tgui(user, "Error: Pool exhausted",
			context = "tgui_process/request_pooled_window")
		alert(user, "TGUI Message: You have too many windows open!", "TGUI Hard Window Limit")
		return null
	return window

/**
 * public
 *
 * Force closes all tgui windows.
 *
 * required user mob
 */
/datum/controller/process/tgui/proc/force_close_all_windows(mob/user)
	log_tgui(user, context = "tgui_process/force_close_all_windows")
	if(user.client)
		user.client.tgui_windows = list()
		for(var/i in 1 to TGUI_WINDOW_HARD_LIMIT)
			var/window_id = TGUI_WINDOW_ID(i)
			user << browse(null, "window=[window_id]")

/**
 * public
 *
 * Force closes the tgui window by window_id.
 *
 * required user mob
 * required window_id string
 */
/datum/controller/process/tgui/proc/force_close_window(mob/user, window_id)
	log_tgui(user, context = "tgui_process/force_close_window")
	// Close all tgui datums based on window_id.
	for(var/datum/tgui/ui in user.tgui_open_uis)
		if(ui.window && ui.window.id == window_id)
			ui.close(can_be_suspended = FALSE)
	// Close window directly just to be sure.
	user << browse(null, "window=[window_id]")

/**
 * public
 *
 * Try to find an instance of a UI, and push an update to it.
 *
 * required user mob The mob who opened/is using the UI.
 * required src_object datum The object/datum which owns the UI.
 * optional ui datum/tgui The UI to be updated, if it exists.
 *
 * return datum/tgui The found UI.
 */
/datum/controller/process/tgui/proc/try_update_ui(mob/user,	datum/src_object, datum/tgui/ui)
	// Look up a UI if it wasn't passed
	if(isnull(ui))
		ui = get_open_ui(user, src_object)
	// Couldn't find a UI.
	if(isnull(ui))
		return null
	ui.process_status()
	// UI ended up with the closed status
	// or is actively trying to close itself.
	// FIXME: Doesn't actually fix the paper bug.
	if(ui.status <= UI_CLOSE)
		ui.close()
		return null
	ui.send_update()
	return ui

/**
 * public
 *
 * Get a open UI given a user and src_object.
 *
 * required user mob The mob who opened/is using the UI.
 * required src_object datum The object/datum which owns the UI.
 *
 * return datum/tgui The found UI.
 */
/datum/controller/process/tgui/proc/get_open_ui(mob/user, datum/src_object)
	// No UIs opened for this src_object
	if(!length(src_object?.open_uis))
		return null
	for(var/datum/tgui/ui in src_object.open_uis)
		// Make sure we have the right user
		if(ui.user == user)
			return ui
	return null

/**
 * public
 *
 * Update all UIs attached to src_object.
 *
 * required src_object datum The object/datum which owns the UIs.
 *
 * return int The number of UIs updated.
 */
/datum/controller/process/tgui/proc/update_uis(datum/src_object)
	// No UIs opened for this src_object
	if(!length(src_object?.open_uis))
		return 0
	var/count = 0
	for(var/datum/tgui/ui in src_object.open_uis)
		// Check if UI is valid.
		if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
			ui.process(force = 1)
			count++
	return count

/**
 * public
 *
 * Close all UIs attached to src_object.
 *
 * required src_object datum The object/datum which owns the UIs.
 *
 * return int The number of UIs closed.
 */
/datum/controller/process/tgui/proc/close_uis(datum/src_object)
	// No UIs opened for this src_object
	if(!length(src_object?.open_uis))
		return 0
	var/count = 0
	for(var/datum/tgui/ui in src_object.open_uis)
		// Check if UI is valid.
		if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
			ui.close()
			count++
	return count

/**
 * public
 *
 * Close all UIs regardless of their attachment to src_object.
 *
 * return int The number of UIs closed.
 */
/datum/controller/process/tgui/proc/close_all_uis()
	var/count = 0
	for(var/datum/tgui/ui in all_uis)
		// Check if UI is valid.
		if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
			ui.close()
			count++
	return count

/**
 * public
 *
 * Update all UIs belonging to a user.
 *
 * required user mob The mob who opened/is using the UI.
 * optional src_object datum If provided, only update UIs belonging this src_object.
 *
 * return int The number of UIs updated.
 */
/datum/controller/process/tgui/proc/update_user_uis(mob/user, datum/src_object)
	var/count = 0
	if(length(user?.tgui_open_uis) == 0)
		return count
	for(var/datum/tgui/ui in user.tgui_open_uis)
		if(isnull(src_object) || ui.src_object == src_object)
			ui.process(force = 1)
			count++
	return count

/**
 * public
 *
 * Close all UIs belonging to a user.
 *
 * required user mob The mob who opened/is using the UI.
 * optional src_object datum If provided, only close UIs belonging this src_object.
 *
 * return int The number of UIs closed.
 */
/datum/controller/process/tgui/proc/close_user_uis(mob/user, datum/src_object)
	var/count = 0
	if(length(user?.tgui_open_uis) == 0)
		return count
	for(var/datum/tgui/ui in user.tgui_open_uis)
		if(isnull(src_object) || ui.src_object == src_object)
			ui.close()
			count++
	return count

/**
 * private
 *
 * Add a UI to the list of open UIs.
 *
 * required ui datum/tgui The UI to be added.
 */
/datum/controller/process/tgui/proc/on_open(datum/tgui/ui)
	ui.user?.tgui_open_uis |= ui
	LAZYLISTOR(ui.src_object.open_uis, ui)
	all_uis |= ui

/**
 * private
 *
 * Remove a UI from the list of open UIs.
 *
 * required ui datum/tgui The UI to be removed.
 *
 * return bool If the UI was removed or not.
 */
/datum/controller/process/tgui/proc/on_close(datum/tgui/ui)
	// Remove it from the list of processing UIs.
	all_uis -= ui
	current_run -= ui
	// If the user exists, remove it from them too.
	if(ui.user)
		ui.user.tgui_open_uis -= ui
	if(ui.src_object)
		LAZYLISTREMOVE(ui.src_object.open_uis, ui)
	return TRUE

/**
 * private
 *
 * Handle client logout, by closing all their UIs.
 *
 * required user mob The mob which logged out.
 *
 * return int The number of UIs closed.
 */
/datum/controller/process/tgui/proc/on_logout(mob/user)
	close_user_uis(user)

/**
 * private
 *
 * Handle clients switching mobs, by transferring their UIs.
 *
 * required user source The client's original mob.
 * required user target The client's new mob.
 *
 * return bool If the UIs were transferred.
 */
/datum/controller/process/tgui/proc/on_transfer(mob/source, mob/target)
	// The old mob had no open UIs.
	if(length(source?.tgui_open_uis) == 0)
		return FALSE
	if(isnull(target.tgui_open_uis) || !istype(target.tgui_open_uis, /list))
		target.tgui_open_uis = list()
	// Transfer all the UIs.
	for(var/datum/tgui/ui in source.tgui_open_uis)
		// Inform the UIs of their new owner.
		ui.user = target
		target.tgui_open_uis.Add(ui)
	// Clear the old list.
	source.tgui_open_uis.Cut()
	return TRUE
