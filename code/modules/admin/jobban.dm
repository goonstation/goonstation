//Job Ban Handling, Modified to utilize code written within the past 6 years.

/proc/jobban_fullban(mob/M, rank, akey)
	if (!M || !M.ckey || !akey) return
	var/server_nice = input(usr, "What server does the ban apply to?", "Ban") as null|anything in list("All", "Roleplay", "Main", "Roleplay Overflow", "Main Overflow")
	var/server = null //heehoo copy pasta
	switch (server_nice)
		if ("Roleplay")
				server = "rp"
		if ("Main")
				server = "main"
		if ("Roleplay Overflow")
				server = "main2"
		if ("Main Overflow")
				server = "main3"
	if(apiHandler.queryAPI("jobbans/add", list("ckey"=M.ckey,"rank"=rank, "akey"=akey, "applicable_server"=server)))
		var/datum/player/player = make_player(M.ckey) //Recache the player.
		player.cached_jobbans = apiHandler.queryAPI("jobbans/get/player", list("ckey"=M.ckey), 1)[M.ckey]
		return 1
	return 0 //Errored.

/proc/jobban_isbanned(mob/M, rank)
	if (!M || !M.ckey ) return

	//you cant be banned from nothing!!
	if (!rank)
		return 0

	var/datum/job/J = find_job_in_controller_by_string(rank)
	if (J && J.no_jobban_from_this_job)
		return 0

	var/datum/player/player = make_player(M.ckey) //Get the player so we can use their bancache.
	if(player.cached_jobbans == null)//Shit they aren't cached.
		player.cached_jobbans = apiHandler.queryAPI("jobbans/get/player", list("ckey"=M.ckey), 1)[M.ckey]


	if(player.cached_jobbans.Find("Everything Except Assistant"))
		if(rank != "Staff Assistant" && rank != "Technical Assistant" && rank != "Medical Assistant")
			return 1

	if(player.cached_jobbans.Find("Engineering Department"))
		if(rank in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
			return 1

	if(player.cached_jobbans.Find("Security Department") || player.cached_jobbans.Find("Security Officer"))
		if(rank in list("Security Officer","Vice Officer","Detective"))
			return 1

	if(player.cached_jobbans.Find("Heads of Staff"))
		if(rank in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director","Medical Director"))
			return 1

	if(player.cached_jobbans.Find("[rank]"))
		return 1
	else
		return 0

/proc/jobban_unban(mob/M, rank)
	if (!M || !M.ckey ) return

	var/datum/player/player = make_player(M.ckey) //Get the player so we can use their bancache.
	if(!player.cached_jobbans.Find("[rank]"))
		return
	apiHandler.queryAPI("jobbans/del", list("ckey"=M.ckey,"rank"=rank))
	if(rank == "Security Department")
		if(player.cached_jobbans.Find("Security Officer"))
			apiHandler.queryAPI("jobbans/del", list("ckey"=M.ckey, "rank"="Security Officer"))
	player.cached_jobbans = apiHandler.queryAPI("jobbans/get/player", list("ckey"=M.ckey), 1)[M.ckey]
