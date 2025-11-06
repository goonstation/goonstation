/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/datum/tgui_window
	var/id
	var/client/client
	var/pooled
	var/pool_index
	var/is_browser = FALSE
	var/status = TGUI_WINDOW_CLOSED
	var/locked = FALSE
	var/visible = FALSE
	var/interface = null // |GOONSTATION-ADD| Interface string used to find a similar window in the pool
	var/datum/tgui/locked_by
	var/datum/subscriber_object
	var/subscriber_delegate
	var/fatally_errored = FALSE
	var/message_queue
	var/list/sent_assets // |GOONSTATION-CHANGE| Initialize list in New instead
	// Vars passed to initialize proc (and saved for later)
	var/initial_strict_mode
	var/initial_fancy
	var/initial_assets
	var/initial_inline_html
	var/initial_inline_js
	var/initial_inline_css
	var/list/oversized_payloads = list()
	var/mouse_event_macro_set = FALSE // |GOONSTATION-ADD| Was removed upstream in https://github.com/tgstation/tgstation/pull/90310

	// |GOONSTATION-ADD| Was removed upstream in https://github.com/tgstation/tgstation/pull/90310
	/**
	 * Static list used to map in macros that will then emit execute events to the tgui window
	 * A small disclaimer though I'm no tech wiz: I don't think it's possible to map in right or middle
	 * clicks in the current state, as they're keywords rather than modifiers.
	 */
	var/static/list/byondToTguiEventMap = list(
		"MouseDown" = "byond/mousedown",
		"MouseUp" = "byond/mouseup",
		"Ctrl" = "byond/ctrldown",
		"Ctrl+UP" = "byond/ctrlup",
	)

/**
 * public
 *
 * Create a new tgui window.
 *
 * required client /client
 * required id string A unique window identifier.
 * optional pooled bool
 * optional interface string - used to find a similar window in the pool
 */
/datum/tgui_window/New(client/client, id, interface, pooled = FALSE) // |GOONSTATION-CHANGE|
	. = ..() // |GOONSTATION-ADD| Probably good I guess
	src.id = id
	src.client = client
	src.client.tgui_windows[id] = src
	src.sent_assets = list() // |GOONSTATION-ADD| Initialized here instead of above
	src.pooled = pooled
	if(pooled)
		src.pool_index = TGUI_WINDOW_INDEX(id)
	src.interface = interface // |GOONSTATION-ADD| Initialize interface string

/datum/tgui_window/disposing() // |GOONSTATION-ADD|
	src.client = null
	src.locked_by = null
	src.subscriber_object = null
	src.subscriber_delegate = null
	. = ..()

/**
 * public
 *
 * Initializes the window with a fresh page. Puts window into the "loading"
 * state. You can begin sending messages right after initializing. Messages
 * will be put into the queue until the window finishes loading.
 *
 * optional strict_mode bool - Enables strict error handling and BSOD.
 * optional fancy bool - If TRUE and if this is NOT a panel, will hide the window titlebar.
 * optional assets list - List of assets to load during initialization.
 * optional inline_html string - Custom HTML to inject.
 * optional inline_js string - Custom JS to inject.
 * optional inline_css string - Custom CSS to inject.
 */
/datum/tgui_window/proc/initialize(
		strict_mode = FALSE,
		fancy = FALSE,
		assets = list(),
		inline_html = "",
		inline_js = "",
		inline_css = ""
	)

	log_tgui(client,
		context = "[id]/initialize",
		window = src)
	if(!client)
		return
	src.initial_fancy = fancy
	src.initial_assets = assets
	src.initial_inline_html = inline_html
	src.initial_inline_js = inline_js
	src.initial_inline_css = inline_css
	status = TGUI_WINDOW_LOADING
	fatally_errored = FALSE
	// Build window options
	var/options = "file=[id].html;can_minimize=0;auto_format=0;"
	// Remove titlebar and resize handles for a fancy window
	if(fancy)
		options += "titlebar=0;can_resize=0;"
	else
		options += "titlebar=1;can_resize=1;"
	// Generate page html
	var/html = tgui_process.basehtml // |GOONSTATION-CHANGE| Different process holder
	html = replacetextEx(html, "\[tgui:windowId\]", id) // |GOONSTATION-CHANGE| Escape closing ], differs to upstream
	html = replacetextEx(html, "\[tgui:strictMode\]", strict_mode) // |GOONSTATION-CHANGE| Escape closing ], differs to upstream
	html = replacetextEx(html, "\[tgui:byondMajor\]", client.byond_version) // |GOONSTATION-ADD| Include BYOND version
	html = replacetextEx(html, "\[tgui:byondMinor\]", client.byond_build) // |GOONSTATION-ADD| Include BYOND build

	// Inject assets
	var/inline_assets_str = ""

	// Handle CDN Assets, Goonstation-style |GOONSTATION-CHANGE|
	for(var/datum/asset/asset in assets)
		if (istype(asset, /datum/asset/group))
			var/datum/asset/group/g = asset
			for(var/subasset in g.subassets)
				inline_assets_str += handle_cdn_asset(get_assets(subasset))
		else
			inline_assets_str += handle_cdn_asset(get_assets(asset.type))

	if(length(inline_assets_str))
		inline_assets_str = "<script>\n" + inline_assets_str + "</script>\n"
	html = replacetextEx(html, "<!-- tgui:assets -->", inline_assets_str) // |GOONSTATION-CHANGE| (-->\n") -> (-->") I realize this syntax is confusing

	// Inject inline HTML
	if (inline_html)
		html = replacetextEx(html, "<!-- tgui:inline-html -->", isfile(inline_html) ? file2text(inline_html) : inline_html)
	// Inject inline JS
	if (inline_js)
		inline_js = "<script>\n'use strict';\n[isfile(inline_js) ? file2text(inline_js) : inline_js]\n</script>"
		html = replacetextEx(html, "<!-- tgui:inline-js -->", inline_js)
	// Inject inline CSS
	if (inline_css)
		inline_css = "<style>\n[isfile(inline_css) ? file2text(inline_css) : inline_css]\n</style>"
		html = replacetextEx(html, "<!-- tgui:inline-css -->", inline_css)
	// Open the window
	client << browse(html, "window=[id];[options]")
	// Detect whether the control is a browser
	is_browser = winexists(client, id) == "BROWSER"
	// Instruct the client to signal UI when the window is closed.
	if(!is_browser)
		winset(client, id, "on-close=\"uiclose [id]\"")

// |GOONSTATION-ADD|
/**
 * private
 *
 * Parses our asset structures for the Goonstation CDN setup
 *
 * return: the string to put in the html window
 */
/datum/tgui_window/proc/handle_cdn_asset(datum/asset/asset)
	var/list/loadAssetStrings = list()
	// Operating locally. Deliver what assets we can manually.
	if (!cdn)
		asset.deliver(client)
		if (istype(asset, /datum/asset/basic))
			var/datum/asset/basic/b = asset
			for (var/url in b.local_assets)
				if(copytext(url, -4) == ".css")
					loadAssetStrings += "Byond.loadCss('[url]', true);\n"
				else if(copytext(url, -3) == ".js")
					loadAssetStrings += "Byond.loadJs('[url]', true);\n"
	else
		var/url_map = asset.get_associated_urls()
		for(var/name in url_map)
			var/url = url_map[name]
			// Not encoding since asset strings are considered safe
			if(copytext(name, -4) == ".css")
				loadAssetStrings += "Byond.loadCss('[url]', true);\n"
			else if(copytext(name, -3) == ".js")
				loadAssetStrings += "Byond.loadJs('[url]', true);\n"
	. = loadAssetStrings.Join("")

/**
 * public
 *
 * Reinitializes the panel with previous data used for initialization.
 */
/datum/tgui_window/proc/reinitialize()
	initialize(
		strict_mode = initial_strict_mode,
		fancy = initial_fancy,
		assets = initial_assets,
		inline_html = initial_inline_html,
		inline_js = initial_inline_js,
		inline_css = initial_inline_css)
	// Resend assets
	for(var/datum/asset/asset in sent_assets)
		send_asset(asset)

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
		&& pooled \
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
 * public
 *
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
 * Subscribes the datum to consume window messages on a specified proc.
 *
 * Note, that this supports only one subscriber, because code for that
 * is simpler and therefore faster. If necessary, this can be rewritten
 * to support multiple subscribers.
 */
/datum/tgui_window/proc/subscribe(datum/object, delegate)
	subscriber_object = object
	subscriber_delegate = delegate

/**
 * public
 *
 * Unsubscribes the datum. Do not forget to call this when cleaning up.
 */
/datum/tgui_window/proc/unsubscribe(datum/object)
	subscriber_object = null
	subscriber_delegate = null

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
	// |GOONSTATION-ADD| Was removed upstream in https://github.com/tgstation/tgstation/pull/90310
	if(mouse_event_macro_set)
		remove_mouse_macro()
	if(can_be_suspended && can_be_suspended())
		log_tgui(client,
			context = "[id]/close (suspending)",
			window = src)
		visible = FALSE
		status = TGUI_WINDOW_READY
		send_message("suspend")
		return
	log_tgui(client,
		context = "[id]/close",
		window = src)
	release_lock()
	visible = FALSE
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
/datum/tgui_window/proc/send_message(type, payload, force)
	if(!client)
		return

	// |GOONSTATION-ADD| Opportunistic cleanup of expired oversized payloads
	prune_oversized_payloads()

	var/message = TGUI_CREATE_MESSAGE(type, payload)
	// Place into queue if window is still loading
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	client << output(message, is_browser \
		? "[id]:update" \
		: "[id].browser:update")

/**
 * public
 *
 * Sends a raw payload to tgui window.
 *
 * required message string JSON+urlencoded blob to send.
 * optional force bool Send regardless of the ready status.
 */
/datum/tgui_window/proc/send_raw_message(message, force)
	if(!client)
		return

	// |GOONSTATION-ADD| Opportunistic cleanup of expired oversized payloads
	prune_oversized_payloads()

	// Place into queue if window is still loading
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	client << output(message, is_browser \
		? "[id]:update" \
		: "[id].browser:update")

// |GOONSTATION-CHANGE| Assets sent differently
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
	sent_assets += list(asset)
	. = asset.deliver(client)
	// |GOONSTATION-CHANGE| We have not implemented separate spritesheet assets yet
	/*
	if(istype(asset, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/spritesheet = asset
		send_message("asset/stylesheet", spritesheet.css_filename())
	*/
	send_raw_message("asset/mappings", asset.get_associated_urls())


/**
 * private
 *
 * Sends queued messages if the queue wasn't empty.
 */
/datum/tgui_window/proc/flush_message_queue()
	if(!client || !message_queue)
		return
	for(var/message in message_queue)
		client << output(message, is_browser \
			? "[id]:update" \
			: "[id].browser:update")
	message_queue = null

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_window/proc/on_message(type, list/payload, list/href_list) // |GOONSTATION-CHANGE| Explicit list for payload/href_list
	// |GOONSTATION-ADD| Opportunistic cleanup of expired oversized payloads
	prune_oversized_payloads()

	// Status can be READY if user has refreshed the window.
	if(type == "ready" && status == TGUI_WINDOW_READY)
		// Resend the assets
		for(var/asset in sent_assets)
			send_asset(asset)
	// Mark this window as fatally errored which prevents it from
	// being suspended.
	if(type == "log" && href_list["fatal"])
		fatally_errored = TRUE
	// Mark window as ready since we received this message from somewhere
	if(status != TGUI_WINDOW_READY)
		status = TGUI_WINDOW_READY
		flush_message_queue()
	// Pass message to UI that requested the lock
	if(locked && locked_by)
		var/prevent_default = locked_by.on_message(type, payload, href_list)
		if(prevent_default)
			return
	// Pass message to the subscriber
	else if(subscriber_object)
		var/prevent_default = call(
			subscriber_object,
			subscriber_delegate)(type, payload, href_list)
		if(prevent_default)
			return
	// If not locked, handle these message types
	switch(type)
		if("ping")
			send_message("ping/reply", payload)
		if("visible")
			visible = TRUE
			SEND_SIGNAL(src, COMSIG_TGUI_WINDOW_VISIBLE, client)
		if("suspend")
			close(can_be_suspended = TRUE)
		if("close")
			close(can_be_suspended = FALSE)
		if("openLink")
			client << link(href_list["url"])
		if("cacheReloaded")
			reinitialize()
		// |GOONSTATION-CHANGE| Not implemented tgui chat
		// if("chat/resend")
			// SSchat.handle_resend(client, payload)
		if("oversizedPayloadRequest")
			var/payload_id = payload["id"]
			var/chunk_count = payload["chunkCount"]
			var/permit_payload = chunk_count <= config.tgui_max_chunk_count
			if(permit_payload)
				create_oversized_payload(payload_id, payload["type"], chunk_count)
			send_message("oversizePayloadResponse", list("allow" = permit_payload, "id" = payload_id))
		if("payloadChunk")
			var/payload_id = payload["id"]
			append_payload_chunk(payload_id, payload["chunk"])
			send_message("acknowlegePayloadChunk", list("id" = payload_id))

// |GOONSTATION-ADD| Was removed upstream in https://github.com/tgstation/tgstation/pull/90310
/datum/tgui_window/proc/set_mouse_macro()
	if(mouse_event_macro_set)
		return

	for(var/mouseMacro in byondToTguiEventMap)
		var/command_template = ".output CONTROL PAYLOAD"
		var/event_message = TGUI_CREATE_MESSAGE(byondToTguiEventMap[mouseMacro], null)
		var target_control = is_browser \
			? "[id]:update" \
			: "[id].browser:update"
		var/with_id = replacetext(command_template, "CONTROL", target_control)
		var/full_command = replacetext(with_id, "PAYLOAD", event_message)

		var/list/params = list(
			"parent" = "default", //Technically this is external to tgui but whatever
			"name" = mouseMacro,
			"command" = full_command
		)


		winset(client, "[mouseMacro]Window[id]Macro", params)
	mouse_event_macro_set = TRUE

// |GOONSTATION-ADD| Was removed upstream in https://github.com/tgstation/tgstation/pull/90310
/datum/tgui_window/proc/remove_mouse_macro()
	if(!mouse_event_macro_set)
		stack_trace("Unsetting mouse macro on tgui window that has none")
	for(var/mouseMacro in byondToTguiEventMap)
		winset(client, null, "[mouseMacro]Window[id]Macro.parent=null")
	mouse_event_macro_set = FALSE


/datum/tgui_window/proc/create_oversized_payload(payload_id, message_type, chunk_count)
	if(oversized_payloads[payload_id])
		stack_trace("Attempted to create oversized tgui payload with duplicate ID.")
		return
	oversized_payloads[payload_id] = list(
		"type" = message_type,
		"count" = chunk_count,
		"chunks" = list(),
		"timeout" = 1.25 SECONDS + TIME // |GOONSTATION-CHANGE|
	)

/datum/tgui_window/proc/append_payload_chunk(payload_id, chunk)
	var/list/payload = oversized_payloads[payload_id]
	if(!payload)
		return
	var/list/chunks = payload["chunks"]
	chunks += chunk
	if(length(chunks) < payload["count"]) // |GOONSTATION-CHANGE| Extend timeout on incomplete payloads, flip logic
		payload["timeout"] = 1.25 SECONDS + TIME // |GOONSTATION-CHANGE|
	else
		payload["timeout"] = 0 // |GOONSTATION-CHANGE|
		var/message_type = payload["type"]
		var/final_payload = chunks.Join()
		remove_oversized_payload(payload_id)
		on_message(message_type, json_decode(final_payload), list("type" = message_type, "payload" = final_payload, "tgui" = TRUE, "window_id" = id))

/datum/tgui_window/proc/remove_oversized_payload(payload_id)
	oversized_payloads -= payload_id

// |GOONSTATION-ADD| Lazy sweep expired oversized payloads (no timers 😿😿😿)
/datum/tgui_window/proc/prune_oversized_payloads()
	if(!length(oversized_payloads))
		return
	var/list/to_remove = list()
	for(var/pid in oversized_payloads)
		var/list/payload = oversized_payloads[pid]
		if(!islist(payload))
			to_remove += pid
			continue
		var/timeout = payload["timeout"]
		if(isnum(timeout) && (timeout <= TIME))
			to_remove += pid
	for(var/pid in to_remove)
		remove_oversized_payload(pid)
