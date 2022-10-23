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
		return 1
	return 0 //Errored.


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
			var/api_response = apiHandler.queryAPI("jobbans/get/player", list("ckey"=M2.ckey), 1)
			if(!length(api_response)) // API unavailable or something
				return FALSE
			if(!M2?.ckey)
				return FALSE // new_player was disposed during api call
			player.cached_jobbans = api_response[M2.ckey]
		cache = player.cached_jobbans
	else if(islist(M))
		cache = M
	else //If we aren't a string this is going to explode.
		cache = apiHandler.queryAPI("jobbans/get/player", list("ckey"=M), 1)[M]

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
		if(rank in list("Security Officer","Security Assistant","Vice Officer","Part-time Vice Officer","Detective"))
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

/proc/jobban_unban(mob/M, rank)//This is full of faff to try and account for raw ckeys and actual players.
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
