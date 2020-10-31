///// FOR EXPORTING DATA TO A SERVER /////

// Called in world.dm at new()
/proc/round_start_data()

	var/message[] = new()
	message["token"] = md5(config.goonhub_parser_key)
	message["round_name"] = url_encode(station_name())
	message["round_server"]  = config.server_id
	message["round_server_number"] = "[serverKey]"
	message["round_status"] = "start"

	// Send data
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[config.goonhub_parser_url][list2params(message)]", "", "")
	request.begin_async()

// Called in gameticker.dm at the end of the round.
/proc/round_end_data(var/reason)

	var/message[] = new()
	message["token"] = md5(config.goonhub_parser_key)
	message["round_name"] = url_encode(station_name())
	message["round_server"]  = config.server_id
	message["round_server_number"] = "[serverKey]"
	message["round_status"] = "end"
	message["end_reason"] = reason
	message["game_type"] = ticker?.mode ? ticker.mode.name : "pre"

	// Send data
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[config.goonhub_parser_url][list2params(message)]", "", "")
	request.begin_async()
