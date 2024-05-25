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
		boutput(world, msg)


	proc/getJob(datum/player/P)
		if (!P?.client?.mob?.mind) return null
		var/job = P.client.mob.mind.assigned_role
		if (job == "MODE") return null
		return job || null


	//Record a participation for a player (or add it to a queue if holding)
	proc/record(datum/player/P)
		set waitfor = FALSE
		if (!P)
			throw EXCEPTION("No player given")

		if (!P.id)
			logTheThing(LOG_DEBUG, null, "No player ID for player during player participation recording. Player: [P.ckey]")
			logTheThing(LOG_DIARY, null, "No player ID for player during player participation recording. Player: [P.ckey]", "admin")
			return

		if (!ticker || !ticker.mode || !ticker.mode.name)
			throw EXCEPTION("Invalid ticker found")

		if (src.debug)
			src.debugLog("(participationRecorder) Called record. player ID: [P.id]. holding: [src.holding]")

		//queue up for eventual transmission via releaseHold
		if (src.holding)
			src.queue += list(list("player_id" = P.id, "job" = src.getJob(P)))

		//send our shiiiit
		else
			try
				var/datum/apiRoute/players/participations/addParticipation = new
				addParticipation.buildBody(P.id, roundId, src.getJob(P))
				apiHandler.queryAPI(addParticipation)
			catch
				logTheThing(LOG_DEBUG, null, "failed to record player participation. Player: [P.ckey]")
				logTheThing(LOG_DIARY, null, "failed to record player participation. Player: [P.ckey]", "admin")


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
			src.debugLog("(participationRecorder) Release hold called. queue: [json_encode(src.queue)]")

		try
			var/datum/apiRoute/players/participationsBulk/addBulkParticipations = new
			addBulkParticipations.buildBody(src.queue, roundId)
			apiHandler.queryAPI(addBulkParticipations)
		catch
			logTheThing(LOG_DEBUG, null, "failed to bulk record player participations. Queue: [json_encode(src.queue)]")
			logTheThing(LOG_DIARY, null, "failed to bulk record player participations. Queue: [json_encode(src.queue)]", "admin")
