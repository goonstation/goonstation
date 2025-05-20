//Job Ban Handling, Modified to utilize code written within the past 6 years.

/proc/jobban_get_for_player(ckey, server)
	if (!ckey) return list()
	try
		var/datum/apiRoute/jobbans/getforplayer/getJobBansForPlayer = new
		getJobBansForPlayer.queryParams = list("ckey" = ckey, "server_id" = server)
		var/datum/apiModel/JobBansForPlayer/jobBansForPlayer = apiHandler.queryAPI(getJobBansForPlayer)
		return jobBansForPlayer.jobs
	catch
		return list()


/proc/jobban_fullban(M, rank, akey)
	if (!M || !akey) return
	if(ismob(M)) //Correct to ckey if provided a mob.
		var/mob/keysource = M
		M = keysource.ckey
	var/datum/game_server/game_server = global.game_servers.input_server(usr, "What server does the ban apply to?", "Ban", can_pick_all=TRUE)
	if(isnull(game_server))
		return null
	var/server_id = istype(game_server) ? game_server.id : null // null = all servers

	try
		var/datum/apiRoute/jobbans/add/addJobBan = new
		addJobBan.buildBody(akey, roundId, server_id, M, rank)
		apiHandler.queryAPI(addJobBan)

		var/datum/player/player = make_player(M) //Recache the player.
		player?.cached_jobbans = jobban_get_for_player(M, server_id)

		var/ircmsg[] = new()
		ircmsg["key"] = M
		ircmsg["rank"] = rank
		ircmsg["akey"] = akey
		ircmsg["applicable_server"] = server_id
		ircbot.export_async("job_ban", ircmsg)

		return TRUE
	catch
		return FALSE


///Can be provided with a mob, a raw cache list, or a ckey. Prefer providing a cache if you can't use a mob, as that reduces API load.
/proc/jobban_isbanned(M, rank)
	var/list/cache
	if(!M)
		return FALSE
	if(ismob(M))
		var/mob/M2 = M
		//if(isnull(M2.client))
			//return FALSE
		var/datum/player/player = make_player(M2.ckey) // Get the player so we can use their bancache.
		if(player.cached_jobbans == null) // Shit they aren't cached.
			var/list/jobBans = jobban_get_for_player(M2.ckey)
			player.cached_jobbans = jobBans
			if(!length(jobBans)) // API unavailable or no bans
				return FALSE
			if(!M2?.ckey)
				return FALSE // new_player was disposed during api call
		cache = player.cached_jobbans
	else if(islist(M))
		cache = M
	else //If we aren't a string this is going to explode.
		cache = jobban_get_for_player(M)

	var/datum/job/J = find_job_in_controller_by_string(rank)
	if(J)
		if (J.no_jobban_from_this_job)
			return FALSE

		if(cache.Find("Everything Except Assistant"))
			if(!istype(J, /datum/job/civilian/staff_assistant))
				return TRUE

		if(cache.Find("Engineering Department"))
			if(J.job_category == JOB_ENGINEERING || istype(J, /datum/job/command/chief_engineer))
				return TRUE

		if(cache.Find("Security Department") || cache.Find("Security Officer"))
			if(J.job_category == JOB_SECURITY || istype(J, /datum/job/command/head_of_security))
				return TRUE

		if(cache.Find("Heads of Staff"))
			if(J.job_category == JOB_COMMAND)
				return TRUE

	if(cache.Find("Ghostdrone"))
		if(rank in list("Ghostdrone","Remy","Bumblespider","Crow"))
			return TRUE

	if(cache.Find("[rank]"))
		return TRUE
	else
		return FALSE

/proc/jobban_unban(mob/M, rank, akey)//This is full of faff to try and account for raw ckeys and actual players.
	var/checkey
	var/list/cache

	if (!ismob(M))
		checkey = M
		cache = jobban_get_for_player(checkey)
	else if (M.ckey)
		checkey = M.ckey
		var/datum/player/player = make_player(checkey) //Get the player so we can use their bancache.
		cache = player.cached_jobbans
		player.cached_jobbans = null //Invalidate their cache.
	else
		return //Mob but no key.
	if(!cache.Find("[rank]"))
		return

	try
		var/datum/apiRoute/jobbans/delete/deleteJobBan = new
		deleteJobBan.buildBody(akey, null, checkey, rank)
		apiHandler.queryAPI(deleteJobBan)

		// Wire note: Hi this is super dumb
		if(rank == "Security Department")
			if(cache.Find("Security Officer"))
				var/datum/apiRoute/jobbans/delete/secDeleteJobBan = new
				secDeleteJobBan.buildBody(akey, null, checkey, "Security Officer")
				apiHandler.queryAPI(secDeleteJobBan)

		var/ircmsg[] = new()
		ircmsg["key"] = checkey
		ircmsg["rank"] = rank
		ircmsg["akey"] = akey
		ircmsg["applicable_server"] = config.server_id
		ircbot.export_async("job_unban", ircmsg)
	catch
		// pass
