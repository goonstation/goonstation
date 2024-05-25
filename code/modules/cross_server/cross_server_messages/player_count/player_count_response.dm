/datum/cross_server_message/player_count_response
	name = "player_count_response"

	receive(list/data, datum/game_server/server)
		var/player_count = data["player_count"]
		server.player_count = player_count
		return TRUE

	send(datum/game_server/server, player_count)
		return src._send(server, list(
			"player_count" = player_count
		))
