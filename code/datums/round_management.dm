/**
 * Collection of methods to handle recording round data to the API
 */

var/global/datum/roundManagement/roundManagement

/datum/roundManagement
	proc/logMsg(msg)
		logTheThing(LOG_DEBUG, null, "<b>Round Management</b> [msg]")
		logTheThing(LOG_DIARY, null, "Round Management: [msg]", "admin")

	/// Record the start of a round (when a server boots up)
	proc/recordStart()
		var/datum/apiModel/Tracked/GameRound/gameRound
		try
			var/datum/apiRoute/rounds/post/addRound = new
			var/rpMode = FALSE
			#ifdef RP_MODE
			rpMode = TRUE
			#endif
			var/testmerges = null
			#ifdef TESTMERGE_PRS
				testmerges = TESTMERGE_PRS
			#endif
			addRound.buildBody(map_setting, config.server_id, rpMode, testmerges)
			gameRound = apiHandler.queryAPI(addRound)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			src.logMsg(error.message)
			return

		roundId = gameRound.id
		src.logMsg("Recorded round start: New round ID #[roundId]")

	/// Record an update to the round (when the game starts)
	proc/recordUpdate(mode = null)
		try
			var/datum/apiRoute/rounds/update/updateRound = new
			updateRound.routeParams = list(roundId)
			updateRound.buildBody(mode)
			apiHandler.queryAPI(updateRound)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			src.logMsg(error.message)
			return

		src.logMsg("Recorded round update: Game type [mode]")

	/// Record the end of a round (just prior to reboot)
	proc/recordEnd(crashed = FALSE)
		try
			var/datum/apiRoute/rounds/end/endRound = new
			endRound.routeParams = list(roundId)
			endRound.buildBody(crashed)
			apiHandler.queryAPI(endRound)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			src.logMsg(error.message)
			return

		src.logMsg("Recorded round end")
