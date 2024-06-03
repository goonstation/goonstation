/datum/cross_server_message/server_sync_response
	name = "server_sync_response"

	receive(list/data, datum/game_server/server)
		server.player_count = data["player_count"]
		server.map = data["map"]
		server.next_map = data["next_map"]
		server.round_time = data["round_time"]
		SEND_SIGNAL(src, COMSIG_SERVER_DATA_SYNCED, data)
		return TRUE

	send(datum/game_server/server)
		var/player_count = 0
		for(var/client/C)
			if (C.stealth && !C.fakekey) // stealthed admins don't count
				continue
			player_count++
		return src._send(server, list(
			"player_count" = player_count,
			"map" = mapSwitcher?.current,
			"next_map" = mapSwitcher?.next,
			"round_time" = round(ticker?.round_elapsed_ticks / 600),
		))
