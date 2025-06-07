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

		#if defined(LIVE_SERVER) && defined(NIGHTSHADE)
		var/list/servers_to_offer = list("streamer1", "streamer2", "streamer3", "main3", "main4")
		#elif defined(LIVE_SERVER)
		var/list/servers_to_offer = list("main1", "main3", "main4")
		#else
		var/list/servers_to_offer = list()
		#endif

		var/list/valid_servers = list()
		for (var/server in servers_to_offer)
			if (config.server_id == server)
				continue

			var/datum/game_server/game_server = game_servers.find_server(server)
			if (game_server)
				valid_servers[game_server.name] = game_server

		if (length(valid_servers) && tgui_process)
			boutput(C, "<span class='ooc adminooc'>Sorry, the player cap of [player_cap] has been reached for this server.</span>")
			var/idx = tgui_input_list(C.mob, "Sorry, the player cap of [player_cap] has been reached for this server. Would you like to be redirected?", "SERVER FULL", valid_servers, timeout = 30 SECONDS)
			var/datum/game_server/redirect_choice = valid_servers[idx]
			logTheThing(LOG_ADMIN, C, "kicked by popcap limit. [redirect_choice ? "Accepted" : "Declined"] redirect[redirect_choice ? " to [redirect_choice.id]" : ""].")
			logTheThing(LOG_DIARY, C, "kicked by popcap limit. [redirect_choice ? "Accepted" : "Declined"] redirect[redirect_choice ? " to [redirect_choice.id]" : ""].", "admin")
			if (global.pcap_kick_messages)
				message_admins("[key_name(C)] was kicked by popcap limit. [redirect_choice ? "<span style='color:limegreen'>Accepted</span>" : "<span style='color:red'>Declined</span>"] redirect[redirect_choice ? " to [redirect_choice.id]" : ""].")
			if (redirect_choice)
				C.changeServer(redirect_choice.id)
		else
			boutput(C, "<span class='ooc adminooc'>Sorry, the player cap of [player_cap] has been reached for this server. You will now be forcibly disconnected</span>")
			if (tgui_process) tgui_alert(C.mob, "Sorry, the player cap of [player_cap] has been reached for this server. You will now be forcibly disconnected", "SERVER FULL")
			logTheThing(LOG_ADMIN, C, "kicked by popcap limit.")
			logTheThing(LOG_DIARY, C, "kicked by popcap limit.", "admin")
			if (global.pcap_kick_messages)
				message_admins("[key_name(C)] was kicked by popcap limit.")

		return FALSE