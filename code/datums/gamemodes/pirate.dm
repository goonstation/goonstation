/datum/game_mode/pirate
	name = "Pirates"
	config_tag = "yarr"
	regular = FALSE
	var/list/datum/mind/pirate_minds = list()
	var/const/minimum_pirates = 2
	var/const/maximum_pirates = 6
	var/const/pop_divisor = 6
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	///IMPORTANT: we need to hold this reference or the allocated region *will* be GCed and overwritten by other areas
	var/datum/allocated_region/pirate_base

	announce()
		boutput(world, "<B>The current game mode is - Pirates!</B>")
		boutput(world, "<B>Pirates are approaching [station_name(1)]! They intend to board us</B>")

	pre_setup()
		. = ..()
		var/list/possible_pirates = list()

		var/num_players = src.roundstart_player_count()

		var/randomizer = rand(pop_divisor+1)
		var/target_antag_count = clamp(round((num_players + randomizer )/ pop_divisor), minimum_pirates, maximum_pirates)

		//just going to piggy back of salvagers pref for ince this gimmick mode
		possible_pirates = get_possible_enemies(ROLE_SALVAGER, target_antag_count)

		// fail if not enough players unless forced
		if (!length(possible_pirates))
			return 0
		if ((master_mode != config_tag)   \
		&& ((length(possible_pirates) < minimum_pirates) || (target_antag_count < minimum_pirates)))
			return 0

		//load in the ship dmm
		src.pirate_base = get_singleton(/datum/mapPrefab/allocated/pirate_ship).load()

		// choose the antags
		var/list/chosen_antags = antagWeighter.choose(pool = possible_pirates, role = ROLE_PIRATE, amount = target_antag_count, recordChosen = 1)

		// store our chosen minds, assign role
		pirate_minds |= chosen_antags
		for (var/datum/mind/pirate in pirate_minds)
			pirate.assigned_role = "MODE" //So they aren't chosen for other jobs.
			pirate.special_role = ROLE_PIRATE
			possible_pirates.Remove(pirate)

 		// pick a captain and first mate
		var/list/L = pirate_minds.Copy()
		var/datum/mind/pirate_captain = pick(L)
		pirate_captain?.special_role = ROLE_PIRATE_CAPTAIN
		L -= pirate_captain
		if (length(L)) // in case we only have 1 pirate
			var/datum/mind/pirate_first_mate = pick(L)
			pirate_first_mate?.special_role = ROLE_PIRATE_FIRST_MATE

		return TRUE

	post_setup()
		. = ..()
		for (var/datum/mind/pirate in pirate_minds)
			equip_antag(pirate)

 		SPAWN(rand(waittime_l, waittime_h))
			send_intercept()

