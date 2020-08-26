/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/datum/tgui_window
	var/id
	var/client/client
	var/tgui_pooled
	var/pool_index
	var/status = TGUI_WINDOW_CLOSED
	var/locked = FALSE
	var/datum/tgui/locked_by
	var/fatally_errored = FALSE
	var/message_queue
	var/list/sent_assets

/**
 * public
 *
 * Create a new tgui window.
 *
 * required client /client
 * required id string A unique window identifier.
 */
/datum/tgui_window/New(client/client, id, tgui_pooled = FALSE)
	src.id = id
	src.client = client
	src.tgui_pooled = tgui_pooled
	src.sent_assets = list()
	if(tgui_pooled)
		client.tgui_windows[id] = src
		src.pool_index = TGUI_WINDOW_INDEX(id)

/**
 * public
 *
 * Initializes the window with a fresh page. Puts window into the "loading"
 * state. You can begin sending messages right after initializing. Messages
 * will be put into the queue until the window finishes loading.
 *
 * optional inline_assets list List of assets to inline into the html.
 */
/datum/tgui_window/proc/initialize(inline_assets = list())
	log_tgui(client, "[id]/initialize")
	if(!client)
		return
	status = TGUI_WINDOW_LOADING
	fatally_errored = FALSE
	message_queue = null
	// Build window options
	var/options = "file=[id].html;can_minimize=0;auto_format=0;"
	// Remove titlebar and resize handles for a fancy window
	if(client.preferences.tgui_fancy)
		options += "titlebar=0;can_resize=0;"
	else
		options += "titlebar=1;can_resize=1;"
	// Generate page html
	var/html = tgui_process.basehtml
	html = replacetextEx(html, "\[tgui:windowId]", id)

	// Process inline assets |GOONSTATION-CHANGE|
	var/list/inline_styles = list()
	var/list/inline_scripts = list()

	// Handle CDN Assets, Goonstation-style |GOONSTATION-ADD|
	for(var/datum/asset/asset in inline_assets)
		if (istype(asset, /datum/asset/group))
			var/datum/asset/group/g = asset
			for(var/subasset in g.subassets)
				handle_cdn_asset(get_assets(subasset), inline_styles, inline_scripts)
		else
			handle_cdn_asset(get_assets(asset.type), inline_styles, inline_scripts)

	html = replacetextEx(html, "<!-- tgui:styles -->", inline_styles.Join())
	html = replacetextEx(html, "<!-- tgui:scripts -->", inline_scripts.Join())

	// Open the window
	client << browse(html, "window=[id];[options]")
	// Instruct the client to signal UI when the window is closed.
	winset(client, id, "on-close=\"uiclose [id]\"")

/** |GOONSTATION-ADD|
 * private
 *
 * Does Goonstation CDN shit to assets, essentially either throws in the url or the filepath to the asset.
 *
 */
/datum/tgui_window/proc/handle_cdn_asset(datum/asset/asset, list/inline_styles, list/inline_scripts)
	// Operating locally. Deliver what assets we can manually.
	if (!cdn)
		asset.deliver(client)
		if (istype(asset, /datum/asset/basic))
			var/datum/asset/basic/b = asset
			for (var/file in b.local_assets)
				if(copytext(file, -4) == ".css")
					inline_styles += "<link rel=\"stylesheet\" type=\"text/css\" href=\"[file]\">\n"
				else if(copytext(file, -3) == ".js")
					inline_scripts += "<script type=\"text/javascript\" defer src=\"[file]\"></script>\n"
	else
		var/url_map = asset.get_associated_urls()
		for(var/name in url_map)
			var/url = url_map[name]
			// Not urlencoding since asset strings are considered safe
			if(copytext(name, -4) == ".css")
				inline_styles += "<link rel=\"stylesheet\" type=\"text/css\" href=\"[url]\">\n"
			else if(copytext(name, -3) == ".js")
				inline_scripts += "<script type=\"text/javascript\" defer src=\"[url]\"></script>\n"

/**
 * public
 *
 * Checks if the window is ready to receive data.
 *
 * return bool
 */
/datum/tgui_window/proc/is_ready()
	return status == TGUI_WINDOW_READY

/**
 * public
 *
 * Checks if the window can be sanely suspended.
 *
 * return bool
 */
/datum/tgui_window/proc/can_be_suspended()
	return !fatally_errored \
		&& tgui_pooled \
		&& pool_index > 0 \
		&& pool_index <= TGUI_WINDOW_SOFT_LIMIT \
		&& status == TGUI_WINDOW_READY

/**
 * public
 *
 * Acquire the window lock. Pool will not be able to provide this window
 * to other UIs for the duration of the lock.
 *
 * Can be given an optional tgui datum, which will hook its on_message
 * callback into the message stream.
 *
 * optional ui /datum/tgui
 */
/datum/tgui_window/proc/acquire_lock(datum/tgui/ui)
	locked = TRUE
	locked_by = ui

/**
 * Release the window lock.
 */
/datum/tgui_window/proc/release_lock()
	// Clean up assets sent by tgui datum which requested the lock
	if(locked)
		sent_assets = list()
	locked = FALSE
	locked_by = null

/**
 * public
 *
 * Close the UI.
 *
 * optional can_be_suspended bool
 */
/datum/tgui_window/proc/close(can_be_suspended = TRUE)
	if(!client)
		return
	if(can_be_suspended && can_be_suspended())
		log_tgui(client, "[id]/close: suspending")
		status = TGUI_WINDOW_READY
		send_message("suspend")
		return
	log_tgui(client, "[id]/close")
	release_lock()
	status = TGUI_WINDOW_CLOSED
	message_queue = null
	// Do not close the window to give user some time
	// to read the error message.
	if(!fatally_errored)
		client << browse(null, "window=[id]")

/**
 * public
 *
 * Sends a message to tgui window.
 *
 * required type string Message type
 * required payload list Message payload
 * optional force bool Send regardless of the ready status.
 */
/datum/tgui_window/proc/send_message(type, list/payload, force)
	if(!client)
		return
	var/message = json_encode(list(
		"type" = type,
		"payload" = payload,
	))
	// Pack for sending via output()
	message = url_encode(message)
	// Place into queue if window is still loading
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	client << output(message, "[id].browser:update")

/**
 * public
 *
 * Makes an asset available to use in tgui.
 *
 * required asset datum/asset
 */
/datum/tgui_window/proc/send_asset(datum/asset/asset)
	if(!client || !asset)
		return
	send_message("asset/mappings", asset.get_associated_urls())
	sent_assets += list(asset)
	asset.deliver(client)

/**
 * private
 *
 * Sends queued messages if the queue wasn't empty.
 */
/datum/tgui_window/proc/flush_message_queue()
	if(!client || !message_queue)
		return
	for(var/message in message_queue)
		client << output(message, "[id].browser:update")
	message_queue = null

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_window/proc/on_message(type, list/payload, list/href_list)
	switch(type)
		if("ready")
			// Status can be READY if user has refreshed the window.
			if(status == TGUI_WINDOW_READY)
				// Resend the assets
				for(var/asset in sent_assets)
					send_asset(asset)
			status = TGUI_WINDOW_READY
		if("log")
			if(href_list["fatal"])
				fatally_errored = TRUE
	// Pass message to UI that requested the lock
	if(locked && locked_by)
		locked_by.on_message(type, payload, href_list)
		flush_message_queue()
		return
	// If not locked, handle these message types
	switch(type)
		if("suspend")
			close(can_be_suspended = TRUE)
		if("close")
			close(can_be_suspended = FALSE)
