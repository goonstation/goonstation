/datum/game_mode/wizard
	name = "Wizard"
	config_tag = "wizard"
	shuttle_available = SHUTTLE_AVAILABLE_DELAY
	antag_token_support = TRUE
	latejoin_antag_compatible = 1
	latejoin_only_if_all_antags_dead = 1
	latejoin_antag_roles = list(ROLE_CHANGELING, ROLE_VAMPIRE)

	var/const/wizards_possible = 5
	var/finished = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/wizard/announce()
	boutput(world, "<B>The current game mode is - Wizard!</B>")
	boutput(world, "<B>There is a <span class='alert'>SPACE WIZARD</span> on the [station_or_ship()]. You can't let him achieve his objective!</B>")

/datum/game_mode/wizard/pre_setup()

	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if(player.ready)
			num_players++

	var/num_wizards = clamp(round(num_players / 12), 1, wizards_possible)

	var/list/possible_wizards = get_possible_enemies(ROLE_WIZARD, num_wizards)

	if (!possible_wizards.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		src.traitors += tplayer
		token_players.Remove(tplayer)
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")
		/*--num_wizards
		num_wizards = max(num_wizards, 0)*/

	var/list/chosen_wizards = antagWeighter.choose(pool = possible_wizards, role = ROLE_WIZARD, amount = num_wizards, recordChosen = 1)
	traitors |= chosen_wizards
	for (var/datum/mind/wizard in traitors)
		wizard.assigned_role = "MODE"
		wizard.special_role = ROLE_WIZARD
		possible_wizards.Remove(wizard)

	return 1

/datum/game_mode/wizard/post_setup()

	for(var/datum/mind/wizard in src.traitors)
		if(!wizard || !istype(wizard))
			src.traitors.Remove(wizard)
			continue

		if(istype(wizard))
			wizard.add_antagonist(ROLE_WIZARD)

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/wizard/send_intercept()
	..(src.traitors)

/datum/game_mode/wizard/proc/get_mob_list()
	var/list/mobs = list()
	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue
		mobs += player
	return mobs

/datum/game_mode/wizard/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue

		if (player.real_name != excluded_name)
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)

datum/game_mode/wizard/check_finished()

	if(emergency_shuttle.location == SHUTTLE_LOC_RETURNED)
		return 1

	if (no_automatic_ending)
		return 0

	return 0

//	OK fuck this shit
/*	//Latejoin bad guys come now if all the wizards are dead rather than the round ending.

	var/wizcount = 0
	//var/wizdeathcount = 0
	var/wincount = 0

	if(ticker.mode.Agimmicks.len > 0)
		for(var/datum/mind/W in ticker.mode.Agimmicks)
			if(!(W in src.traitors))
				wizards += W

	for (var/datum/mind/W in wizards)
		wizcount++
		var/objectives_completed = 0
		for(var/datum/objective/objective in W.objectives)
			if(objective.check_completion()) objectives_completed++
		if(objectives_completed == W.objectives.len) wincount++
		//if(!W.current || isdead(W.current)) wizdeathcount++

	//if (wizcount == wizdeathcount) return 1
	if (wizcount == wincount)
		boutput(world, "wizcount [wizcount], wincount [wincount], ending round")
		return 1

	else return 0*/
