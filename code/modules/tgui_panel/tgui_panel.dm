/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at

/datum/tgui_panel/New(client/client)
	..()
	src.client = client
	window = new(client, "browseroutput")
	window.subscribe(src, PROC_REF(on_message))

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/initialize(force = FALSE)
	set waitfor = FALSE
	// Minimal sleep to defer initialization to after client constructor
	sleep(1 DECI SECOND)
	initialized_at = world.time
	// Perform a clean initialization
	window.initialize(inline_assets = list(
		get_assets(/datum/asset/basic/tgui_panel),
		get_assets(/datum/asset/basic/fontawesome),
	))
	// Other setup
	request_telemetry()
	SPAWN(4 SECONDS)
		src.on_initialize_timed_out()

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out()
	client << "<h2><span class='alert'>Failed to load fancy chat, click <a href='?src=\ref[src];reload_tguipanel=1'>HERE</a> to attempt to reload it.</span></h2>"

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_panel/proc/on_message(type, payload)
	if (type == "ready")
		broken = FALSE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
				),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
		return TRUE
	if (type == "audio/setAdminMusicVolume")
		var/volume = payload["volume"]
		if (volume)
			client?.setVolume(VOLUME_CHANNEL_ADMIN, volume * 100)
		return TRUE
	if (type == "telemetry")
		analyze_telemetry(payload)
		return TRUE
	if (type == "contextact")
		var/command = null
		var/target = null
		if (payload["command"])
			command = payload["command"]
		if (payload["target"])
			target = payload["target"]
		if (target && command)
			src.client?.handle_ctx_menu(command, target)
			return TRUE

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")
