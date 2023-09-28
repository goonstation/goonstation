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
		var/eventsLength = length(src.events)
		if (!eventsLength || (!src.connected && !src.connect())) return

		var/list/eventsToSend = src.events.Copy(1, eventsLength + 1)
		var/res = rustg_redis_lpush(config.goonhub_events_channel, json_encode(eventsToSend))
		var/list/lRes = json_decode(res)

		if (lRes["success"])
			src.events.Cut(1, eventsLength + 1)
			src.eventsPushed += eventsLength
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
