var/global/datum/eventRecorder/eventRecorder

/datum/eventRecorder
	var/connected = FALSE
	var/list/events = list()
	var/eventsPushed = 0

	New()
		..()
		src.connect()

	/// Connect to the external event service
	proc/connect()
		var/addr = "redis://"
		if (config.goonhub_events_password)
			addr += ":[config.goonhub_events_password]@"
		addr += "[config.goonhub_events_endpoint]:[config.goonhub_events_port]"
		var/res = rustg_redis_connect_rq(addr)

		if (res)
			src.connected = FALSE
			var/logMsg = "Failed to connect to Goonhub Event Recording service. Reason: [res]"
			logTheThing(LOG_DEBUG, null, logMsg)
			logTheThing(LOG_DIARY, null, logMsg, "debug")
			return FALSE

		src.connected = TRUE
		return TRUE

	/// Push the event queue to the server
	proc/process()
		if (!length(src.events) || (!src.connected && !src.connect())) return

		var/res = rustg_redis_lpush(config.goonhub_events_channel, json_encode(src.events))
		var/list/lRes = json_decode(res)

		if (lRes["success"])
			src.eventsPushed += length(src.events)
			src.events.Cut()
		else
			var/msg = lRes["content"]
			var/logMsg = "Failed to push data to Goonhub Event Recording service. Reason: [msg]"
			logTheThing(LOG_DEBUG, null, logMsg)
			logTheThing(LOG_DIARY, null, logMsg, "debug")

	/// Add an event to the event queue
	proc/add(datum/eventRecord/event)
		var/list/data = event.body.ToList()
		data["type"] = event.eventType
		data["round_id"] = 0 // TODO: populate from global
		data["created_at"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

		src.events += list(data)
