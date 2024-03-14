var/global/datum/eventRecorder/eventRecorder

/datum/eventRecorder
	/// Whether the event recorder is enabled
	var/enabled = TRUE
	/// Whether the event recorder is connected to a redis server
	var/connected = FALSE
	/// Events currently waiting to be pushed to the redis server
	var/list/events = list()
	/// Events added before a global roundId existed, to be pushed when it is available
	var/list/queue = list()
	/// The total amount of events pushed to the redis server
	var/eventsPushed = 0

	New()
		..()
		src.connect()

	/// Connect to the external event service
	proc/connect()
		if (!config.goonhub_events_endpoint || !config.goonhub_events_port || !config.goonhub_events_channel)
			src.enabled = FALSE
			var/logMsg = "Disabled Goonhub Event Recording service due to missing config"
			logTheThing(LOG_DEBUG, null, "<b>Event Recorder:</b> [logMsg]")
			logTheThing(LOG_DIARY, null, "Event Recorder: [logMsg]", "debug")
			return

		var/addr = "redis://"
		if (config.goonhub_events_password)
			addr += ":[config.goonhub_events_password]@"
		addr += "[config.goonhub_events_endpoint]:[config.goonhub_events_port]"
		var/res = rustg_redis_connect_rq(addr)

		if (res)
			src.connected = FALSE
			var/logMsg = "Failed to connect to Goonhub Event Recording service. Reason: [res]"
			logTheThing(LOG_DEBUG, null, "<b>Event Recorder:</b> [logMsg]")
			logTheThing(LOG_DIARY, null, "Event Recorder: [logMsg]", "debug")
			return FALSE

		src.connected = TRUE
		return TRUE

	/// Push the event queue to the server
	proc/process()
		if (!src.enabled || (!length(src.events) && !length(src.queue)) || (!src.connected && !src.connect())) return

		// Process any events added before a roundId was available and add them to the list to push
		if (length(src.queue) && roundId)
			for (var/list/queuedEvent in src.queue)
				queuedEvent["round_id"] = roundId
				src.events += list(queuedEvent)
			src.queue.Cut()

		if (!length(src.events)) return

		var/res = rustg_redis_lpush(config.goonhub_events_channel, json_encode(src.events))
		var/list/lRes = json_decode(res)

		if (lRes["success"])
			src.eventsPushed += length(src.events)
			src.events.Cut()
		else
			var/msg = lRes["content"]
			var/logMsg = "Failed to push data to Goonhub Event Recording service. Reason: [msg]"
			logTheThing(LOG_DEBUG, null, "<b>Event Recorder:</b> [logMsg]")
			logTheThing(LOG_DIARY, null, "Event Recorder: [logMsg]", "debug")

	/// Add an event to the event queue
	proc/add(datum/eventRecord/event)
		if (!src.enabled) return

		var/list/data = event.body.ToList()
		data["type"] = event.eventType
		data["round_id"] = roundId
		data["created_at"] = "[time2text(world.realtime, "YYYY-MM-DD")] [time2text(world.timeofday, "hh:mm:ss")]"

		if (roundId)
			src.events += list(data)
		else
			src.queue += list(data)

	/// Display debug information
	proc/debug()
		var/list/html = list()
		html += "<strong>Enabled:</strong> [src.enabled ? "Yes" : "No"]<br>"
		html += "<strong>Connected:</strong> [src.connected ? "Yes" : "No"]<br>"
		html += "<strong>Events Pending:</strong> [length(src.events)]<br>"
		html += "<strong>Events Queued:</strong> [length(src.queue)]<br>"
		html += "<strong>Events Pushed:</strong> [src.eventsPushed]<br>"
		usr.Browse(html.Join(), "window=eventRecorderDebug")

/client/proc/debug_event_recorder()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug Event Recorder"
	set desc = "Display debug information about the event recorder"
	ADMIN_ONLY
	eventRecorder.debug()
