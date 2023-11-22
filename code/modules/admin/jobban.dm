//Job Ban Handling, Modified to utilize code written within the past 6 years.

/proc/jobban_fullban(M, rank, akey)
	if (!M || !akey) return
	if(ismob(M)) //Correct to ckey if provided a mob.
		var/mob/keysource = M
		M = keysource.ckey
	var/datum/game_server/game_server = global.game_servers.input_server(usr, "What server does the ban apply to?", "Ban", can_pick_all=TRUE)
	if(isnull(game_server))
		return null
	var/server_id = istype(game_server) ? game_server.id : null // null = all servers
	if(apiHandler.queryAPI("jobbans/add", list("ckey"=M,"rank"=rank, "akey"=akey, "applicable_server"=server_id)))
		var/datum/player/player = make_player(M) //Recache the player.
		player?.cached_jobbans = apiHandler.queryAPI("jobbans/get/player", list("ckey"=M), 1)[M]
		var/ircmsg[] = new()
		ircmsg["key"] = M
		ircmsg["rank"] = rank
		ircmsg["akey"] = akey
		ircmsg["applicable_server"] = server_id
		ircbot.export_async("job_ban", ircmsg)
		return 1
	return 0 //Errored.


///Can be provided with a mob, a raw cache list, or a ckey. Prefer providing a cache if you can't use a mob, as that reduces API load.
/proc/jobban_isbanned(M, rank)
	var/list/cache
	if(!M)
		return FALSE
	var/datum/player/player = null
	if(ismob(M))
		var/mob/M2 = M
		player = make_player(M2.ckey) // Get the player so we can use their bancache.
	else if(islist(M))
		cache = M
	else if(istext(M))
		player = make_player(M)
	else
		CRASH("jobban_isbanned() called with invalid argument type '[M]'.")

	if(isnull(cache) && player)
		if(isnull(player.cached_jobbans)) // Shit they aren't cached.
			var/api_response = apiHandler.queryAPI("jobbans/get/player", list("ckey"=player.ckey), 1)
			if(!length(api_response)) // API unavailable or something
				return FALSE
			player.cached_jobbans = api_response[player.ckey]
		cache = player.cached_jobbans
		if(isnull(cache))
			CRASH("jobban cache is null for [player.ckey] after an API fetch")
	else if(isnull(cache))
		CRASH("jobban cache is null and there is no player datum, this should not happen: [M], [player]")

	var/datum/job/J = find_job_in_controller_by_string(rank)
	if (J?.no_jobban_from_this_job)
		return FALSE



	if(cache.Find("Everything Except Assistant"))
		if(rank != "Staff Assistant" && rank != "Technical Assistant" && rank != "Medical Assistant")
			return TRUE

	if(cache.Find("Engineering Department"))
		if(rank in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner"))
			return TRUE

	if(cache.Find("Security Department") || cache.Find("Security Officer"))
		if(rank in list("Security Officer","Security Assistant","Vice Officer","Detective"))
			return TRUE

	if(cache.Find("Heads of Staff"))
		if(rank in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director","Medical Director"))
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
		cache = apiHandler.queryAPI("jobbans/get/player", list("ckey"=checkey), 1)[checkey]
	else if (M.ckey)
		checkey = M.ckey
		var/datum/player/player = make_player(checkey) //Get the player so we can use their bancache.
		cache = player.cached_jobbans
		player.cached_jobbans = null //Invalidate their cache.
	else
		return //Mob but no key.
	if(!cache.Find("[rank]"))
		return

	apiHandler.queryAPI("jobbans/del", list("ckey"=checkey,"rank"=rank))
	if(rank == "Security Department")
		if(cache.Find("Security Officer"))
			apiHandler.queryAPI("jobbans/del", list("ckey"=checkey, "rank"="Security Officer"))
	var/ircmsg[] = new()
	ircmsg["key"] = checkey
	ircmsg["rank"] = rank
	ircmsg["akey"] = akey
	ircmsg["applicable_server"] = config.server_id
	ircbot.export_async("job_unban", ircmsg)
