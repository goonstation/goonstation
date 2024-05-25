/datum/cross_server_message/player_count_response
	name = "player_count_response"

	receive(list/data, datum/game_server/server)
		var/player_count = data["player_count"]
		// Handle the received player count, e.g., log it or store it
		logTheThing(LOG_DEBUG, null, "<b>CSM:</b> Received player count from [server.id]: [player_count]")
		server.player_count = player_count
		// You can store it in a global list or process it further here
		return TRUE

	send(datum/game_server/server, player_count)
		logTheThing(LOG_DEBUG, null, "<b>CSM:</b> Sending player count response to [server.id] with count [player_count]")
		return src._send(server, list(
			"player_count" = player_count
		))
