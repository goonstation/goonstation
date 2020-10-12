///// FOR EXPORTING DATA TO A SERVER /////

// Called in world.dm at new()
/proc/round_start_data()
	set background = 1

	var/message[] = new()
	message["token"] = md5(config.goonhub_parser_key)
	message["round_name"] = url_encode(station_name())
	message["round_server"]  = config.server_id
	message["round_server_number"] = "[serverKey]"
	message["round_status"] = "start"

	world.Export("[config.goonhub_parser_url][list2params(message)]")

// Called in gameticker.dm at the end of the round.
/proc/round_end_data(var/reason)
	set background = 1

	var/message[] = new()
	message["token"] = md5(config.goonhub_parser_key)
	message["round_name"] = url_encode(station_name())
	message["round_server"]  = config.server_id
	message["round_server_number"] = "[serverKey]"
	message["round_status"] = "end"
	message["end_reason"] = reason
	message["game_type"] = ticker?.mode ? ticker.mode.name : "pre"

	world.Export("[config.goonhub_parser_url][list2params(message)]")
