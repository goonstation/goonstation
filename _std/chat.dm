/**
 * Allows sending a message to a specified chat, given a custom tag.
 *
 * @param message The text for the message we're sending
 * @param channel_tag The tag (set in the TGS control panel) to send the message to. This is optional, and sends to all channels if not specified. Setting to -1 will send to admins only (yes this is jank)
 * @return nothing
 */
/proc/discord_send(message, channel_tag = null)
	if(!world.TgsAvailable())
		return

	// Sanitize
	var/static/list/filtered_chars = list(
		"@" = "\[at]",
		"#" = "\[hash]"
	)
	for(var/char in filtered_chars)
		message = replacetext(message, char, filtered_chars[char])

	// send everywhere
	if(channel_tag == null)
		world.TgsTargetedChatBroadcast(message, FALSE)
	else if(channel_tag == -1)
		world.TgsTargetedChatBroadcast(message, TRUE)
	else
		var/datum/tgs_version/V = world.TgsApiVersion()
		if(V.suite < 4)
			// Running TGS 3
			world.TgsTargetedChatBroadcast(message, FALSE)
		else
			var/list/datum/tgs_chat_channel/channels = list()
			// API version 4 or later
			for(var/datum/tgs_chat_channel/C in world.TgsChatChannelInfo())
				if(C.custom_tag == channel_tag)
					channels += C
			world.TgsChatBroadcast(message, channels)


/* CHAT COMMANDS */
/datum/tgs_chat_command/ping
	name = "ping"
	help_text = "Check that the server's alive"

/datum/tgs_chat_command/ping/Run(datum/tgs_chat_user/sender, params)
	return "Pong, [sender.friendly_name]!"

/datum/tgs_chat_command/check
	name = "check"
	help_text = "Get information about the current round"

// Oh god I can feel the jank
/datum/tgs_chat_command/check/proc/pad_time(num)
	var/str = "[num]"
	if(length(str) < 2)
		// single digits
		str = "0[str]"
	return str

/datum/tgs_chat_command/check/Run(datum/tgs_chat_user/sender, params)
	// Yoink
	var/elapsed
	if (current_state < GAME_STATE_FINISHED)
		if (current_state <= GAME_STATE_PREGAME) elapsed = "STARTING"
		else if (current_state > GAME_STATE_PREGAME)
			// Number of elapsed seconds
			var/temp = round(ticker.round_elapsed_ticks / 10)
			// Hours
			var/hours = round(temp / 3600)
			temp -= hours * 3600
			// Minutes
			var/minutes = round(temp / 60)
			temp -= minutes * 60
			// Seconds
			var/seconds = temp
			elapsed = "[pad_time(hours)]:[pad_time(minutes)]:[pad_time(seconds)] elapsed"
	else if (current_state == GAME_STATE_FINISHED) elapsed = "ENDING"
	return "[config.server_name] ([station_name]) [clients.len] players Map: [getMapNameFromID(map_setting)] Mode: [(ticker?.hide_mode) ? "secret" : master_mode]; [elapsed] -- <byond://[world.internet_address]:[world.port]>"

/datum/tgs_chat_command/reboot
	name = "reboot"
	help_text = "<normal|hard|tgs>"
	admin_only_goon_sucks = TRUE

/datum/tgs_chat_command/reboot/Run(datum/tgs_chat_user/sender, params)
	if(!params)
		return "Insufficient parameters"
	var/list/all_params = splittext(params, " ")
	if(length(all_params) != 1)
		return "Invalid amount of parameters"
	var/mode = all_params[1]
	var/init_by = "Initiated by an Admin remotely through the TGS Relay."
	switch(mode)
		if("normal")
			out(world, "<span class='bold notice'>Initiating world restart, requested remotely through the TGS relay.</span>")
			Reboot_server()
		if("hard")
			out(world, "<span class='bold notice'>World reboot - [init_by]</span>")
			world.Reboot()
		if("tgs")
			out(world, "<span class='bold notice'>Server restart - [init_by]</span>")
			world.TgsEndProcess()
		else
			return "Invalid reboot mode"
