/datum/cross_server_message/server_sync_request
	name = "server_sync_request"

	receive(list/data, datum/game_server/server)
		var/datum/cross_server_message/server_sync_response/server_sync_response = get_singleton(/datum/cross_server_message/server_sync_response)
		server_sync_response.send(server)
		return TRUE
	send(datum/game_server/server)
		return src._send(server, list())
