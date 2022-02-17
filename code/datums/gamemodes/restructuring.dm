/datum/game_mode/restructuring
	name = "Corporate Restructuring"
	config_tag = "restructuring"
/*
/datum/game_mode/restructuring/announce()
	boutput(world, "<span class='alert'><B>GLOBAL TRANSMISSION FROM HEAD OFFICE: A CORPORATE RESTRUCTURING IS TO TAKE PLACE</B></span>")
	boutput(world, "<span class='alert'><B>Stay tuned for further news; note that we do care for our employees and any layoffs will be dealt with discretion and compassion</B></span>")


/datum/game_mode/restructuring/post_setup()
	setup_game()
	var/list/mobs = get_mob_list()
	while (mobs.len == 0)
		sleep 30
		mobs = get_mob_list()
	SPAWN(12 SECONDS)
		pick_target()

/datum/game_mode/restructuring/proc/pick_target(who)
	var/mob/target
	var/mob/target_desc

	if (!who)
		target = pick(get_mob_list())
		target_desc = get_target_desc(target)
		boutput(world, "<span class='alert'><B>HEAD OFFICE: [target_desc] is accused of attempting to start a Union and is now considered a threat to the station. Terminate the employee immediately.</b></span>")
	else
		target = who
		target_desc = get_target_desc(target)
		boutput(world, "<span class='alert'><B>HEAD OFFICE: [target_desc] is accused of being a giant shitty homophobe or some shit. Terminate the employee immediately.</b></span>")
	ticker.target = target

	target.store_memory("Head office has ordered your downsizing. Ruh roh", 0)

	for_by_tcl(M, /mob/living/silicon/ai)
		boutput(M, "These are your laws now:")
		M.set_zeroth_law("[target_desc] is not human.")
		M.show_laws()

/datum/game_mode/restructuring/check_win()
	var/list/left_alive = get_mob_list()
	if (left_alive.len == 1)
		var/thewinner = the_winner()
		boutput(world, "<span class='alert'><B>HEAD OFFICE: Thanks to his superior brown-nosing abilities, [thewinner] has been promoted to senior management! Congratulations!</span>")
		return 1
	else if (left_alive.len == 0)
		boutput(world, "<span class='alert'><B>HEAD OFFICE: Cost cutting measures have achieved 100% efficiency. Thank you for understanding our position during this volatile economic downturn.</span>")
		return 1
	else
		if(!isdead(ticker.target))
			return 0
		boutput(world, "<span class='alert'><B>HEAD OFFICE: It seems we have made a mistake in our paperwork. The previous target for termination was chosen based on race, sex, and/or religious beliefs, which is against company policy. Please cancel previous termination request.</span>")
		pick_target()
		return 0

/datum/game_mode/restructuring/proc/get_mob_list()
	var/list/mobs = list()
	for(var/mob/M in mobs)
		if (M.stat<2 && M.client && ishuman(M))
			mobs += M
	return mobs

/datum/game_mode/restructuring/proc/the_winner()
	for(var/mob/M in mobs)
		if (M.stat<2 && M.client && ishuman(M))
			return M.name

/datum/game_mode/restructuring/proc/get_target_desc(mob/target) //return a useful string describing the target
	var/targetrank = null
	for(var/datum/db_record/R as anything in data_core.general.records)
		if (R["name"] == target.real_name)
			targetrank = R["rank"]
	if(!targetrank)
		return "[target.name]"
	return "[target.name] the [targetrank]"
*/
