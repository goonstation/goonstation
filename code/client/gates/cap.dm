/datum/client_auth_gate/cap
	check(client/C)
		if (IsLocalClient(C) || !player_capa) return TRUE

		// Admins and mentors are allowed to bypass the cap
		if (C.client_auth_intent.admin || C.client_auth_intent.mentor) return TRUE

		// The player cap has not been reached
		if (total_clients_for_cap() < player_cap) return TRUE

		// The player is allowed to bypass the cap
		if (C.client_auth_intent.can_bypass_cap)
			boutput(C, "<span class='ooc adminooc'>Welcome! The server has reached the player cap of [player_cap], but you are allowed to bypass the player cap!</span>")
			return TRUE

		// The player is in the grace period
		if (client_has_cap_grace(C))
			boutput(C, "<span class='ooc adminooc'>Welcome! The server has reached the player cap of [player_cap], but you were recently disconnected and were caught by the grace period!</span>")
			return TRUE

		logTheThing(LOG_ADMIN, C, "kicked by popcap limit.")
		logTheThing(LOG_DIARY, C, "kicked by popcap limit.", "admin")
		if (global.pcap_kick_messages)
			message_admins("[key_name(C)] was kicked by popcap limit.")

		return FALSE

/datum/client_auth_gate/cap/get_failure_message(client/C)
	#if defined(LIVE_SERVER) && defined(NIGHTSHADE)
	var/list/servers_to_offer = list("streamer1", "streamer2", "streamer3", "main3", "main4")
	#elif defined(LIVE_SERVER)
	var/list/servers_to_offer = list("main1", "main3", "main4")
	#else
	var/list/servers_to_offer = list()
	#endif

	var/server_buttons = ""
	for (var/server in servers_to_offer)
		if (config.server_id == server)
			continue

		var/datum/game_server/game_server = game_servers.find_server(server)
		if (game_server)
			server_buttons += {"<a href="[game_server.url]" class="button">[game_server.name]</a>"}

	return {"
		<h1>Server Full</h1>
		Sorry, the server has reached the player cap of [player_cap].
		<br><br>
		[server_buttons ? "Would you like to be redirected to another server?<br><br>[server_buttons]" : "Please try again later."]
	"}
