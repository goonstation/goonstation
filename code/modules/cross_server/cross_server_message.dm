ABSTRACT_TYPE(/datum/cross_server_message)
/datum/cross_server_message
	var/name = null /// identifier of this message type

	/// override to do something when this message is received
	proc/receive(list/data, datum/game_server/server)

	/// override to let people send this message with custom arguments, use _send with a key-value list to send the actual message
	proc/send(datum/game_server/server, ...)

	proc/_send(datum/game_server/server, list/data)
		data["type"] = "game_servers"
		data["subtype"] = src.name
		return server.send_message(data)
