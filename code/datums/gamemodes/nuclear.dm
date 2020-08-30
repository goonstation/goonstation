/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	shuttle_available = 2
	var/target_location_name = null // The name of our target area. Used for text output.
	var/list/target_location_type = list() // Our area.type, which can be multiple (e.g. medbay).
	var/agent_number = 1
	var/list/datum/mind/syndicates = list()
	var/finished = 0
	var/nuke_detonated = 0 //Has the nuke gone off?
	var/agent_radiofreq = 0 //:h for syndies, randomized per round
	var/obj/machinery/nuclearbomb/the_bomb = null
	var/bomb_check_timestamp = 0 // See check_finished().
#if ASS_JAM
	var/const/agents_possible = 30 // on ass jam theres up to 30 nukies to compensate for the warcrime of the kinetitech
#else
	var/const/agents_possible = 6 //If we ever need more syndicate agents. cogwerks - raised from 5
#endif

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/token_players_assigned = 0

	do_antag_random_spawns = 0

/datum/game_mode/nuclear/announce()
	boutput(world, "<B>The current game mode is - Nuclear Emergency!</B>")
	boutput(world, "<B>[syndicate_name()] operatives are approaching [station_name(1)]! They intend to destroy the [station_or_ship()] with a nuclear warhead.</B>")

/datum/game_mode/nuclear/pre_setup()
	var/list/possible_syndicates = list()

	if (!landmarks[LANDMARK_SYNDICATE])
		boutput(world, "<span class='alert'><b>ERROR: couldn't find Syndicate spawn landmark, aborting nuke round pre-setup.</b></span>")
		return 0

	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (player.ready)
			num_players++
#if ASS_JAM
	var/num_synds = max(1, min(round(num_players / 3), agents_possible))
#else
	var/num_synds = max(1, min(round(num_players / 4), agents_possible))
#endif

	possible_syndicates = get_possible_syndicates(num_synds)

	if (!islist(possible_syndicates) || possible_syndicates.len < 1)
		boutput(world, "<span class='alert'><b>ERROR: couldn't assign any players as Syndicate operatives, aborting nuke round pre-setup.</b></span>")
		return 0

	// I wandered in and made things hopefully a bit easier to work with since we have multiple maps now - Haine
	var/list/list/target_locations = null

	if (map_settings && islist(map_settings.valid_nuke_targets) && map_settings.valid_nuke_targets.len)
		target_locations = map_settings.valid_nuke_targets
	else
		if (ismap("COGMAP2"))
			target_locations = list("the main security room" = list(/area/station/security/main),
			"the central research sector hub" = list(/area/station/science),
			"the cargo bay (QM)" = list(/area/station/quartermaster/office),
			"the thermo-electric generator room" = list(/area/station/engine/core),
			"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
			"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
			"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
			"the net cafe" = list(/area/station/crew_quarters/info),
			"the artifact lab" = list(/area/station/science/artifact),
			"the genetics lab" = list(/area/station/medical/research))

		else if (ismap("DONUT3"))
			target_locations = list("the cargo bay (QM)" = list(/area/station/quartermaster/office),
			"inner engineering (surrounding the singularity, not in it)" = list(/area/station/engine/inner),
			"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
			"the inner hall of the medbay" = list(/area/station/medical/medbay),
			"the main hallway in research" = list(/area/station/science),
			"the chapel" = list(/area/station/chapel/main),
			"the escape hallway" = list(/area/station/hallway/secondary/exit),
			"the Research Director's office" = list(/area/station/crew_quarters/hor),
			"the Chief Engineer's office" = list(/area/station/engine/engineering/ce),
			"the kitchen" = list(/area/station/crew_quarters/kitchen))

		else if (ismap("DESTINY") || ismap("CLARION"))
			target_locations = list("the main security room" = list(/area/station/security/main),
			"the central research sector hub" = list(/area/station/science),
			"the cargo bay (QM)" = list(/area/station/quartermaster/office),
			"the thermo-electric generator room" = list(/area/station/engine/core),
			"the refinery (arc smelter)" = list(/area/station/mining/refinery),
			"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
			"the bar" = list(/area/station/crew_quarters/bar),
			"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
			"the artifact lab" = list(/area/station/science/artifact),
			"the robotics lab" = list(/area/station/medical/robotics))

		else // COG1
			target_locations = list("the main security room" = list(/area/station/security/main),
			"the central research sector hub" = list(/area/station/science),
			"the cargo bay (QM)" = list(/area/station/quartermaster/office),
			"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
			"the central warehouse" = list(/area/station/storage/warehouse),
			"the courtroom" = list(/area/station/crew_quarters/courtroom, /area/station/crew_quarters/juryroom),
			"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
			"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
			"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
			"the robotics lab" = list(/area/station/medical/robotics))
			//"the public pool" = list(/area/station/crew_quarters/pool)) // Don't ask, it just fits all criteria. Deathstar weakness or something.

	if (!islist(target_locations) || !target_locations.len)
		target_locations = list("the station (anywhere)" = list(/area/station))
		message_admins("<span class='alert'><b>CRITICAL BUG:</b> nuke mode setup encountered an error while trying to choose a target location for the bomb and the target has defaulted to anywhere on the station! The round will be able to be played like this but it will be unbalanced! Please inform a coder!")
		logTheThing("debug", null, null, "<b>CRITICAL BUG:</b> nuke mode setup encountered an error while trying to choose a target location for the bomb and the target has defaulted to anywhere on the station.")

#if ASS_JAM
	var/station_only = prob(40)
	target_locations = list()
	for(var/area/A in world)
		var/has_turfs = 0
		for (var/turf/T in A)
			has_turfs = 1
			break
		if(!has_turfs)
			break
		if(station_only && !istype(A, /area/station))
			continue
		if(!(A.name in target_locations))
			target_locations[A.name] = list(A.type)
		else
			target_locations[A.name].Add(A.type)
#endif

	target_location_name = pick(target_locations)
	if (!target_location_name)
		boutput(world, "<span class='alert'><b>ERROR: couldn't assign target location for bomb, aborting nuke round pre-setup.</b></span>")
		message_admins("<span class='alert'><b>CRITICAL BUG:</b> nuke mode setup encountered an error while trying to choose a target location for the bomb (could not select area name)!")
		return 0

	target_location_type = target_locations[target_location_name]
	if (!target_location_type)
		boutput(world, "<span class='alert'><b>ERROR: couldn't assign target location for bomb, aborting nuke round pre-setup.</b></span>")
		message_admins("<span class='alert'><b>CRITICAL BUG:</b> nuke mode setup encountered an error while trying to choose a target location for the bomb (could not select area type)!")
		return 0

	// now that we've done everything that could cause the round to fail to start (in this proc, at least), we can deal with antag tokens
	token_players = antag_token_list()
	for (var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		syndicates += tplayer
		token_players.Remove(tplayer)
		num_synds--
		num_synds = max(num_synds, 0)
		logTheThing("admin", tplayer.current, null, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")

	var/list/chosen_syndicates = antagWeighter.choose(pool = possible_syndicates, role = "nukeop", amount = num_synds, recordChosen = 1)
	syndicates |= chosen_syndicates
	for (var/datum/mind/syndicate in syndicates)
		syndicate.assigned_role = "MODE" //So they aren't chosen for other jobs.
		syndicate.special_role = "nukeop"
		possible_syndicates.Remove(syndicate)

	agent_radiofreq = random_radio_frequency()

	return 1

/datum/game_mode/nuclear/post_setup()
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord", "General", "Warlord", "Commissar")
	var/leader_selected = 0

	var/list/callsign_pool_keys = list("nato", "melee_weapons", "colors", "birds", "mammals", "moons")
	//Alphabetical agent callsign lists are delcared here, seperated in to catagories.
	var/list/callsign_list = strings("agent_callsigns.txt", pick(callsign_pool_keys))

	for(var/datum/mind/synd_mind in syndicates)
		bestow_objective(synd_mind,/datum/objective/specialist/nuclear)

		var/obj_count = 1
		boutput(synd_mind.current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
		for(var/datum/objective/objective in synd_mind.objectives)
			boutput(synd_mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

		synd_mind.store_memory("The bomb must be armed in <B>[src.target_location_name]</B>.", 0, 0)
		boutput(synd_mind.current, "We have identified a major structural weakness in the [station_or_ship()]'s design. Arm the bomb in <B>[src.target_location_name]</B> to obliterate [station_name(1)].")

		if(!leader_selected)
			synd_mind.current.set_loc(pick_landmark(LANDMARK_SYNDICATE_BOSS))
			if(!synd_mind.current.loc)
				synd_mind.current.set_loc(pick_landmark(LANDMARK_SYNDICATE))
			synd_mind.current.real_name = "[syndicate_name()] [leader_title]"
			equip_syndicate(synd_mind.current, 1)
			new /obj/item/device/audio_log/nuke_briefing(synd_mind.current.loc, target_location_name)
			if (ishuman(synd_mind.current))
				var/mob/living/carbon/human/M = synd_mind.current
				M.equip_if_possible(new /obj/item/pinpointer/disk(M), M.slot_in_backpack)
			else
				new /obj/item/pinpointer/disk(synd_mind.current.loc)
			leader_selected = 1
		else
			synd_mind.current.set_loc(pick_landmark(LANDMARK_SYNDICATE))
			var/callsign = pick(callsign_list)
			synd_mind.current.real_name = "[syndicate_name()] Operative [callsign]" //new naming scheme
			callsign_list -= callsign
			equip_syndicate(synd_mind.current, 0)
		boutput(synd_mind.current, "<span class='alert'>Your headset allows you to communicate on the syndicate radio channel by prefacing messages with :h, as (say \":h Agent reporting in!\").</span>")

		synd_mind.current.antagonist_overlay_refresh(1, 0)
		SHOW_NUKEOP_TIPS(synd_mind.current)

	the_bomb = new /obj/machinery/nuclearbomb(pick_landmark(LANDMARK_NUCLEAR_BOMB))
	new /obj/storage/closet/syndicate/nuclear(pick_landmark(LANDMARK_NUCLEAR_CLOSET))

	for(var/turf/T in landmarks[LANDMARK_SYNDICATE_GEAR_CLOSET])
		new /obj/storage/closet/syndicate/personal(T)
	for(var/turf/T in landmarks[LANDMARK_SYNDICATE_BOMB])
	new /obj/spawner/newbomb/timer/syndicate(pick_landmark(LANDMARK_SYNDICATE_BOMB))
	for(var/turf/T in landmarks[LANDMARK_SYNDICATE_BREACHING_CHARGES])
		for(var/i = 1 to 5)
			new /obj/item/breaching_charge/thermite(T)

	SPAWN_DBG (rand(waittime_l, waittime_h))
		send_intercept()

	return

/datum/game_mode/nuclear/check_finished()
	// First ticker.process() call runs before the bomb is actually spawned.
	if (src.bomb_check_timestamp == 0)
		src.bomb_check_timestamp = world.time

	if (src.finished)
		return 1

	if (src.nuke_detonated)
		finished = -2
		return 1

	if (emergency_shuttle.location == SHUTTLE_LOC_RETURNED)
		if (the_bomb && the_bomb.armed)
			// Minor Syndicate Victory - crew escaped but bomb was armed and counting down
			finished = -1
			return 1
		if ((!the_bomb || the_bomb.disposed || (the_bomb && !the_bomb.armed)))
			if (all_operatives_dead())
				// Major Station Victory - bombing averted, all operatives dead/captured
				finished = 2
				return 1
			else
				// Minor Station Victory - bombing averted, but operatives escaped
				finished = 1
				return 1

	if (no_automatic_ending)
		return 0

	if (the_bomb && the_bomb.armed && the_bomb.det_time && !the_bomb.disposed)
		// don't end the game if the bomb is armed and counting, even if the ops are all dead
		return 0

	if (all_operatives_dead())
		finished = 2
		// Major Station Victory - bombing averted, all operatives dead/captured
		return 1

	// Minor or major Station Victory - bombing averted in any case.
	if (src.bomb_check_timestamp && world.time > src.bomb_check_timestamp + 300)
		if (!src.the_bomb || src.the_bomb.disposed || !istype(src.the_bomb, /obj/machinery/nuclearbomb))
			if (src.all_operatives_dead())
				finished = 2
			else
				finished = 1
			return 1

	return 0

/datum/game_mode/nuclear/declare_completion()
	switch(finished)
		if(-2) // Major Synd Victory - nuke successfully detonated
			boutput(world, "<FONT size = 3><B>Total Syndicate Victory</B></FONT>")
			boutput(world, "The operatives have destroyed [station_name(1)]!")
#ifdef DATALOGGER
			game_stats.Increment("traitorwin")
#endif
		if(-1) // Minor Synd Victory - station abandoned while nuke armed
			boutput(world, "<FONT size = 3><B>Syndicate Victory</B></FONT>")
			boutput(world, "The crew of [station_name(1)] abandoned the [station_or_ship()] while the bomb was armed! The [station_or_ship()] will surely be destroyed!")
#ifdef DATALOGGER
			game_stats.Increment("traitorwin")
#endif
		if(0) // Uhhhhhh
			boutput(world, "<FONT size = 3><B>Stalemate</B></FONT>")
			boutput(world, "Everybody loses!")
		if(1) // Minor Crew Victory - station evacuated, bombing averted, operatives survived
			boutput(world, "<FONT size = 3><B>Crew Victory</B></FONT>")
			boutput(world, "The crew of [station_name(1)] averted the bombing! However, some of the operatives survived.")
#ifdef DATALOGGER
			game_stats.Increment("traitorloss")
#endif
		if(2) // Major Crew Victory - bombing averted, all ops dead/captured
			boutput(world, "<FONT size = 3><B>Total Crew Victory</B></FONT>")
			boutput(world, "The crew of [station_name(1)] averted the bombing and eliminated all Syndicate operatives!")
#ifdef DATALOGGER
			game_stats.Increment("traitorloss")
#endif

	if(finished > 0)
		var/value = world.load_intra_round_value("nukie_loss")
		if(isnull(value))
			value = 0
		world.save_intra_round_value("nukie_loss", value + 1)
	else if(finished < 0)
		var/value = world.load_intra_round_value("nukie_win")
		if(isnull(value))
			value = 0
		world.save_intra_round_value("nukie_win", value + 1)

	for(var/datum/mind/M in syndicates)
		var/syndtext = ""
		if(M.current) syndtext += "<B>[M.key] played [M.current.real_name].</B> "
		else syndtext += "<B>[M.key] played an operative.</B> "
		if (!M.current) syndtext += "(Destroyed)"
		else if (isdead(M.current)) syndtext += "(Killed)"
		else if (M.current.z != 1) syndtext += "(Missing)"
		else syndtext += "(Survived)"
		boutput(world, syndtext)

		for (var/datum/objective/objective in M.objectives)
#ifdef CREW_OBJECTIVES
			if (istype(objective, /datum/objective/crew)) continue
#endif
			if (istype(objective, /datum/objective/miscreant)) continue

			if (objective.check_completion())
				if (!isnull(objective.medal_name) && !isnull(M.current))
					M.current.unlock_medal(objective.medal_name, objective.medal_announce)

	..() //Listing custom antagonists.

/datum/game_mode/nuclear/proc/all_operatives_dead()
	var/opcount = 0
	var/opdeathcount = 0
	for(var/datum/mind/M in syndicates)
		opcount++
		if(!M.current || isdead(M.current) || inafterlife(M.current) || isVRghost(M.current) || issilicon(M.current) || isghostcritter(M.current))
			opdeathcount++ // If they're dead
			continue

		var/turf/T = get_turf(M.current)
		if (!T)
			continue
		if (istype(T.loc, /area/station/security/brig))
			if(M.current.hasStatus("handcuffed"))
				opdeathcount++
				// If they're in a brig cell and cuffed

	if (opcount == opdeathcount) return 1
	else return 0

/datum/game_mode/nuclear/proc/get_possible_syndicates(minimum_syndicates=1)
	var/list/candidates = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (ishellbanned(player)) continue //No treason for you
		if ((player.ready) && !(player.mind in syndicates) && !(player.mind in token_players) && !candidates.Find(player.mind))
			if(player.client.preferences.be_syndicate)
				candidates += player.mind

	if(candidates.len < minimum_syndicates)
		logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Not enough players with be_syndicate set to yes, including players who don't want to be syndicates in the pool.")
		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue
			if (ishellbanned(player)) continue //No treason for you

			if ((player.ready) && !(player.mind in syndicates) && !(player.mind in token_players) && !candidates.Find(player.mind))
				candidates += player.mind

				if ((minimum_syndicates > 1) && (candidates.len >= minimum_syndicates))
					break

	if(candidates.len < 1)
		return list()
	else
		return candidates

/datum/game_mode/nuclear/send_intercept()
	var/intercepttext = "Cent. Com. Update Requested staus information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "changeling")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(ticker.minds))

	for (var/obj/machinery/communications_dish/C in by_type[/obj/machinery/communications_dish])
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")


/datum/game_mode/nuclear/proc/random_radio_frequency()
	var/f = 0
	var/list/blacklisted = list(0, 1451, 1457) // The old blacklist was rather incomplete and thus ineffective (Convair880).
	blacklisted.Add(R_FREQ_BLACKLIST_HEADSET)
	blacklisted.Add(R_FREQ_BLACKLIST_INTERCOM)

	do
		f = rand(1352, 1439)

	while (blacklisted.Find(f))

	return f

/datum/game_mode/nuclear/process()
	set background = 1
	..()
	return

var/syndicate_name = null
/proc/syndicate_name()
	if (syndicate_name)
		return syndicate_name

	var/name = ""

	// Prefix
#ifdef XMAS
	name += pick("Merry", "Jingle", "Holiday", "Santa", "Gift", "Elf", "Jolly")
#else
	name += pick("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib", "Funk", "Joint")
#endif
	// Suffix
	if (prob(80))
		name += " "

		// Full
		if (prob(60))
			name += pick("Syndicate", "Consortium", "Collective", "Corporation", "Consolidated", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Family", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive", "Cartel")
		// Broken
		else
			name += pick("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
			name += pick("", "-")
			name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Code")
	// Small
	else
		name += pick("-", "*", "")
		name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive")

	syndicate_name = name
	return name
