/*
* Literally just a thing that records player participation in a round (as defined by normal joining, no observing/admin trickery)
* Also it collates data during round start so it doesn't freakin' shotgun blast the API with 50 different requests ok
*/

var/global/datum/participationRecorder/participationRecorder


/datum/participationRecorder
	var/debug = 0
	var/holding = 0 //are we on hold for the time being?
	var/list/queue = list() //if holding, queue holds data to send once hold is removed


	New(debugMode)
		..()
		src.debug = debugMode ? debugMode : 0


	proc/debugLog(msg)
		out(world, msg)


	//Record a participation for a player (or add it to a queue if holding)
	proc/record(ckey)
		if (!ckey)
			throw EXCEPTION("No ckey given")

		if (!ticker || !ticker.mode || !ticker.mode.name)
			throw EXCEPTION("Invalid ticker found")

		if (src.debug)
			src.debugLog("(participationRecorder) Called record. ckey: [ckey]. holding: [src.holding]")

		//queue up for eventual transmission via releaseHold
		if (src.holding)
			src.queue += ckey

		//send our shiiiit
		else
			var/list/payload = list(
				"ckey" = ckey,
				"round_mode" = ticker.mode.name
			)
			#ifdef RP_MODE
			payload["rp_mode"] = true
			#endif
			apiHandler.queryAPI("participation/record", payload)


	//Set holding on, which enables queuing of participation data for the duration
	proc/setHold()
		if (src.debug)
			src.debugLog("(participationRecorder) Hold set")

		src.holding = 1


	//Release hold, disabling queuing and sending a BIG OL BLOB of data to the API
	proc/releaseHold()
		if (!src.holding || !length(src.queue)) return
		src.holding = 0

		if (src.debug)
			src.debugLog("(participationRecorder) Release hold called. round_name: [ticker.mode.name]. queue: [json_encode(src.queue)]")

		var/list/payload = list(
			"round_mode" = ticker.mode.name
		)
		#ifdef RP_MODE
		payload["rp_mode"] = true
		#endif

		var/count = 0
		for (var/ckey in src.queue)
			payload["ckeys\[[count]]"] = ckey
			count++

		apiHandler.queryAPI("participation/record-multiple", payload)



world/New()
	. = ..()
	participationRecorder = new()
	//participationRecorder = new(1) //Enable debug
