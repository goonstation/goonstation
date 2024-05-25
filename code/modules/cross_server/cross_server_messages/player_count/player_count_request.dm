/datum/cross_server_message/player_count_request
	name = "player_count_request"

	receive(list/data, datum/game_server/server)
		var/player_count = 0
		for(var/client/C)
			if (C.stealth && !C.fakekey) // stealthed admins don't count
				continue
			player_count++

		var/datum/cross_server_message/player_count_response/player_count_response_csm = get_singleton(/datum/cross_server_message/player_count_response)
		player_count_response_csm.send(server, player_count)
		return TRUE
	send(datum/game_server/server)
		return src._send(server, list())
