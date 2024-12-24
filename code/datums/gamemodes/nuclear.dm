///This amount of potential target locations are picked, up to every defined plant spot for the map
#define AMOUNT_OF_VALID_NUKE_PLANT_LOCATIONS 2

var/global/list/nuke_op_color_matrix = list("#394470","#c65039", "#63662c")
var/global/list/nuke_op_camo_matrix = null

/datum/game_mode/nuclear
	name = "Nuclear Emergency"
	config_tag = "nuclear"
	shuttle_available = SHUTTLE_AVAILABLE_DELAY
	/// The name of our target area(s). Used for text output.
	var/list/target_location_names = list()
	/// Our area.type, which can be multiple per plant location (e.g. medbay).
	var/list/target_location_type = list()
	/// An output ready summation of every 1 to n plant locations, for the couple of places outside of this file that care for that.
	var/concatenated_location_names
	var/agent_number = 1
	var/list/datum/mind/syndicates = list()
	var/finished = 0
	var/nuke_detonated = 0 //Has the nuke gone off?
	var/agent_radiofreq = 0 //:h for syndies, randomized per round
	var/obj/machinery/nuclearbomb/the_bomb = null
	var/bomb_check_timestamp = 0 // See check_finished().
	var/minimum_players = 15 // Minimum ready players for the mode
	var/const/agents_possible = 10 //If we ever need more syndicate agents. cogwerks - raised from 5
	var/podbay_authed = FALSE // Whether or not we authed our podbay yet
	var/obj/machinery/computer/battlecruiser_podbay/auth_computer = null // The auth computer in the cairngorm so we can auth it

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/token_players_assigned = 0

	do_antag_random_spawns = 0
	antag_token_support = TRUE
	escape_possible = 0

/datum/game_mode/nuclear/announce()
	boutput(world, "<B>The current game mode is - Nuclear Emergency!</B>")
	boutput(world, "<B>[syndicate_name()] operatives are approaching [station_name(1)]! They intend to destroy the [station_or_ship()] with a nuclear warhead.</B>")

/datum/game_mode/nuclear/pre_setup()
	var/list/possible_syndicates = list()

	if (!landmarks[LANDMARK_SYNDICATE])
		//boutput(world, SPAN_ALERT("<b>ERROR: couldn't find Syndicate spawn landmark, aborting nuke round pre-setup.</b>"))
		logTheThing(LOG_DEBUG, null, "Failed to find Syndicate spawn landmark, aborting nuke round pre-setup.")
		return 0

	var/num_players = src.roundstart_player_count()
#ifndef ME_AND_MY_40_ALT_ACCOUNTS
	if (num_players < minimum_players)
		message_admins("<b>ERROR: Minimum player count of [minimum_players] required for Nuclear game mode, aborting nuke round pre-setup.</b>")
		logTheThing(LOG_GAMEMODE, src, "Failed to start nuclear mode. [num_players] players were ready but a minimum of [minimum_players] players is required. ")
		return 0
#endif

	var/num_synds = clamp( round(num_players / 6 ), 2, agents_possible)

	possible_syndicates = get_possible_enemies(ROLE_NUKEOP, num_synds)

#ifndef ME_AND_MY_40_ALT_ACCOUNTS
	if (!islist(possible_syndicates) || length(possible_syndicates) < 2)
		//boutput(world, SPAN_ALERT("<b>ERROR: couldn't assign at least two players as Syndicate operatives, aborting nuke round pre-setup.</b>"))
		return 0
#endif

	// I wandered in and made things hopefully a bit easier to work with since we have multiple maps now - Haine
	var/list/list/target_locations = null

	if (map_settings && islist(map_settings.valid_nuke_targets) && length(map_settings.valid_nuke_targets))
		target_locations = map_settings.valid_nuke_targets
	else
		if (ismap("COGMAP2"))
			target_locations = list("the main security room" = list(/area/station/security/main),
			"the central research sector hub" = list(/area/station/science/lobby),
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
			"the main hallway in research" = list(/area/station/science/lobby),
			"the chapel" = list(/area/station/chapel/sanctuary),
			"the escape hallway" = list(/area/station/hallway/secondary/exit),
			"the Research Director's office" = list(/area/station/crew_quarters/hor),
			"the Chief Engineer's office" = list(/area/station/engine/engineering/ce),
			"the kitchen" = list(/area/station/crew_quarters/kitchen))

		else if (ismap("DESTINY") || ismap("CLARION"))
			target_locations = list("the main security room" = list(/area/station/security/main),
			"the central research sector hub" = list(/area/station/science/lobby),
			"the cargo bay (QM)" = list(/area/station/quartermaster/office),
			"the thermo-electric generator room" = list(/area/station/engine/core),
			"the refinery (arc smelter)" = list(/area/station/mining/refinery),
			"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
			"the bar" = list(/area/station/crew_quarters/bar),
			"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
			"the artifact lab" = list(/area/station/science/artifact),
			"the robotics lab" = list(/area/station/medical/robotics))

		else if (ismap ("DONUT2"))
			target_locations = list("the cargo bay (QM)" = list(/area/station/quartermaster/office),
			"the public market" = list(/area/station/crew_quarters/market),
			"the stock exchange" = list(/area/station/crew_quarters/stockex),
			"the chapel" = list(/area/station/chapel/sanctuary),
			"the bridge" = list(/area/station/bridge),
			"the crew lounge" = list(/area/station/crew_quarters/quarters),
			"the main brig area" = list(/area/station/security/brig),
			"the main station pod bay" = list(/area/station/hangar/main))


		else // COG1
			target_locations = list("the main security room" = list(/area/station/security/main),
			"the central research sector hub" = list(/area/station/science/lobby),
			"the cargo bay (QM)" = list(/area/station/quartermaster/office),
			"the engineering control room" = list(/area/station/engine/engineering),
			"the central warehouse" = list(/area/station/storage/warehouse),
			"the courtroom" = list(/area/station/crew_quarters/courtroom, /area/station/crew_quarters/juryroom),
			"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
			"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
			"the main bridge" = list(/area/station/bridge),
			"the robotics lab" = list(/area/station/medical/robotics))
			//"the public pool" = list(/area/station/crew_quarters/pool)) // Don't ask, it just fits all criteria. Deathstar weakness or something.

	if (!islist(target_locations) || !length(target_locations))
		target_locations = list("the station (anywhere)" = list(/area/station))
		message_admins(SPAN_ALERT("<b>CRITICAL BUG:</b> nuke mode setup encountered an error while trying to choose a target location for the bomb and the target has defaulted to anywhere on the station! The round will be able to be played like this but it will be unbalanced! Please inform a coder!"))
		logTheThing(LOG_DEBUG, null, "<b>CRITICAL BUG:</b> nuke mode setup encountered an error while trying to choose a target location for the bomb and the target has defaulted to anywhere on the station.")

	//bomb plant location strings
	if (length(target_locations) > AMOUNT_OF_VALID_NUKE_PLANT_LOCATIONS)
		do
			var/thing = pick(target_locations)
			if (!(thing in target_location_names))
				target_location_names += thing //no duplicates pls
		while (length(target_location_names) < AMOUNT_OF_VALID_NUKE_PLANT_LOCATIONS)
	else //would love to just copy the list but it's associative so
		for(var/i in 1 to length(target_locations))
			target_location_names += target_locations[i]
	if (!target_location_names)
		//boutput(world, SPAN_ALERT("<b>ERROR: couldn't assign target location for bomb, aborting nuke round pre-setup.</b>"))
		message_admins(SPAN_ALERT("<b>CRITICAL BUG:</b> nuke mode setup encountered an error while trying to choose a target location for the bomb (could not select area name)!"))
		return 0

	//bomb plant location typepaths
	if (length(target_location_names) == 1)
		target_location_type = target_locations[target_location_names[1]]
	else //Add every single typepath into a list
		for(var/i in 1 to length(target_location_names))
			target_location_type += target_locations[target_location_names[i]]
	src.create_plant_location_markers(target_locations, target_location_names)

	if (!target_location_type)
		//boutput(world, SPAN_ALERT("<b>ERROR: couldn't assign target location for bomb, aborting nuke round pre-setup.</b>"))
		message_admins(SPAN_ALERT("<b>CRITICAL BUG:</b> nuke mode setup encountered an error while trying to choose a target location for the bomb (could not select area type)!"))
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
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")

	var/list/chosen_syndicates = antagWeighter.choose(pool = possible_syndicates, role = ROLE_NUKEOP, amount = num_synds, recordChosen = 1)
	syndicates |= chosen_syndicates
	for (var/datum/mind/syndicate in syndicates)
		syndicate.assigned_role = "MODE" //So they aren't chosen for other jobs.
		syndicate.special_role = ROLE_NUKEOP
		possible_syndicates.Remove(syndicate)

	agent_radiofreq = random_radio_frequency()
	protected_frequencies += agent_radiofreq

	return 1

/datum/game_mode/nuclear/proc/pick_leader()
	RETURN_TYPE(/datum/mind)
	var/list/datum/mind/possible_leaders = list()
	for(var/datum/mind/mind in syndicates)
		if(mind.current.client?.preferences?.be_syndicate_commander && mind.current.has_medal("Manhattan Project"))
			possible_leaders += mind
	if(length(possible_leaders))
		return pick(possible_leaders)
	else
		for(var/datum/mind/mind in syndicates)
			if(mind.current.client?.preferences?.be_syndicate_commander)
				possible_leaders += mind
	if(length(possible_leaders))
		return pick(possible_leaders)
	return pick(syndicates)

/datum/game_mode/nuclear/post_setup()
	var/datum/mind/leader_mind = src.pick_leader()
	leader_mind.special_role = ROLE_NUKEOP_COMMANDER

	//Building the plant location strings
	var/to_store_in_mind
	var/to_output
	concatenated_location_names = target_location_names[1]
	//Note: (almost) every location name string already has a leading "the"
	switch(length(target_location_names))
		if(1) //Classic, the strings we're all familiar with
			to_store_in_mind = "The bomb must be armed in <B>[src.target_location_names[1]]</B>."
			to_output = "We have identified a major structural weakness in the [station_or_ship()]'s design. Arm the bomb in <B>[src.target_location_names[1]]</B> to obliterate [station_name(1)]."
		if(2) //Worth making some nice adjusted strings for
			concatenated_location_names += " or [src.target_location_names[2]]"
			to_store_in_mind = "The bomb must be armed in <B>[src.target_location_names[1]]</B> or <B>[src.target_location_names[2]]</B>."
			to_output = "We have identified two major structural weaknesses in the [station_or_ship()]'s design. Arm the bomb in either <B>[src.target_location_names[1]]</B> or <B>[src.target_location_names[2]]</B> to obliterate [station_name(1)]."
		if(3 to INFINITY) //Alright now you're just getting list slop
			for(var/i in 2 to length(target_location_names)) //The first entry is already added above the switch
				concatenated_location_names += (((i != length(target_location_names)) ? ", " : " or ") + target_location_names[i])

			to_store_in_mind = "The bomb must be armed in one of the following:<B>[concatenated_location_names]</B>."
			to_output = "We have identified several major structural weaknesses in the [station_or_ship()]'s rickety excuse of a design. To obliterate [station_name(1)], arm the bomb in one of the following: <B>[concatenated_location_names]</B>."

	for(var/datum/mind/synd_mind in syndicates)
		var/obj_count = 1
		boutput(synd_mind.current, SPAN_NOTICE("You are a [syndicate_name()] agent!"))
		for(var/datum/objective/objective in synd_mind.objectives)
			boutput(synd_mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

		synd_mind.store_memory(to_store_in_mind, 0, 0)
		boutput(synd_mind.current, to_output)

		equip_antag(synd_mind)

		if(synd_mind == leader_mind)
			var/mob/living/carbon/human/H = synd_mind.current
			H.equip_if_possible(new /obj/item/device/audio_log/nuke_briefing(H, concatenated_location_names), SLOT_R_HAND)

	the_bomb = new /obj/machinery/nuclearbomb(pick_landmark(LANDMARK_NUCLEAR_BOMB))
	the_bomb.gives_medal = TRUE
	OTHER_START_TRACKING_CAT(the_bomb, TR_CAT_GHOST_OBSERVABLES) // STOP_TRACKING done in bomb/disposing()
	new /obj/storage/closet/syndicate/nuclear(pick_landmark(LANDMARK_NUCLEAR_CLOSET))

	for(var/turf/T in landmarks[LANDMARK_SYNDICATE_GEAR_CLOSET])
		new /obj/storage/closet/syndicate/personal(T)
	for(var/turf/T in landmarks[LANDMARK_SYNDICATE_BOMB])
	new /obj/spawner/newbomb/timer/syndicate(pick_landmark(LANDMARK_SYNDICATE_BOMB))
	for(var/turf/T in landmarks[LANDMARK_SYNDICATE_BREACHING_CHARGES])
		for(var/i = 1 to 5)
			new /obj/item/breaching_charge/thermite(T)

	for_by_tcl(computer,/obj/machinery/computer/battlecruiser_podbay)
		auth_computer = computer

	SPAWN(rand(waittime_l, waittime_h))
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
		if (the_bomb?.armed)
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

	if (the_bomb?.armed && the_bomb.det_time && !the_bomb.disposed)
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

/datum/game_mode/nuclear/victory_msg()
	return "<FONT size = 3><B>[victory_headline()]</B></FONT><br>[victory_body()]</span>"

/datum/game_mode/nuclear/victory_headline()
	switch(finished)
		if(-2) // Major Synd Victory - nuke successfully detonated
			return "Total Syndicate Victory"
		if(-1) // Minor Synd Victory - station abandoned while nuke armed
			return "Syndicate Victory"
		if(0) // Uhhhhhh
			return "Stalemate"
		if(1) // Minor Crew Victory - station evacuated, bombing averted, operatives survived
			return "Crew Victory"
		if(2) // Major Crew Victory - bombing averted, all ops dead/captured
			return "Total Crew Victory"

/datum/game_mode/nuclear/victory_body()
	switch(finished)
		if(-2)
			return "The operatives have destroyed [station_name(1)]!"
		if(-1)
			return "The crew of [station_name(1)] abandoned the [station_or_ship()] while the bomb was armed! The [station_or_ship()] will surely be destroyed!"
		if(0)
			return "Everybody loses!"
		if(1)
			return "The crew of [station_name(1)] averted the bombing! However, some of the operatives survived."
		if(2)
			return "The crew of [station_name(1)] averted the bombing and eliminated all Syndicate operatives!"

/datum/game_mode/nuclear/declare_completion()
	boutput(world, src.victory_msg())

	if(finished > 0)
		var/value = world.load_intra_round_value("nukie_loss")
#ifdef DATALOGGER
		game_stats.Increment("traitorloss")
#endif
		if(isnull(value))
			value = 0
		world.save_intra_round_value("nukie_loss", value + 1)
	else if(finished < 0)
		var/value = world.load_intra_round_value("nukie_win")
#ifdef DATALOGGER
		game_stats.Increment("traitorwin")
#endif
		if(isnull(value))
			value = 0
		world.save_intra_round_value("nukie_win", value + 1)

	for(var/datum/mind/M in syndicates)
		var/syndtext = ""
		if(M.current) syndtext += "<B>[M.key] played [M.current.real_name].</B> "
		else syndtext += "<B>[M.key] played an operative.</B> "
		if (!M.current) syndtext += "(Destroyed)"
		else if (isdead(M.current)) syndtext += "(Killed)"
		else if (get_z(M.current) != Z_LEVEL_STATION) syndtext += "(Missing)"
		else syndtext += "(Survived)"
		boutput(world, syndtext)

		for (var/datum/objective/objective in M.objectives)
#ifdef CREW_OBJECTIVES
			if (istype(objective, /datum/objective/crew)) continue
#endif
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

/datum/game_mode/nuclear/send_intercept()
	..(ticker.minds)
/datum/game_mode/nuclear/proc/random_radio_frequency()
	. = 0
	var/list/blacklisted = list(0, 1451, 1457) // The old blacklist was rather incomplete and thus ineffective (Convair880).
	blacklisted.Add(R_FREQ_BLACKLIST)

	do
		. = rand(1352, 1439)

	while (. in blacklisted)

/datum/game_mode/nuclear/proc/create_plant_location_markers(var/list/target_locations, var/list/target_location_names)
	// Find the centres of the plant sites.
	for (var/i in 1 to length(target_location_names))
		var/marker_name
		var/list/area/areas = list()
		for (var/area_type in target_locations[target_location_names[i]])
			areas += get_areas(area_type)

		var/total_x = 0
		var/total_y = 0
		var/total_turfs = 0

		for (var/area/area in areas)
			if (area.z != Z_LEVEL_STATION)
				continue
			for (var/turf/T in area)
				total_x += T.x
				total_y += T.y
				total_turfs += 1
			if (!marker_name)
				marker_name = capitalize(area.name)
		var/target_x = round(total_x / total_turfs)
		var/target_y = round(total_y / total_turfs)

		// If its not in the right area we can at least try randomly
		var/marker_area = get_area(locate(target_x, target_y, Z_LEVEL_STATION))
		if (!(marker_area in areas))
			var/turf/T = pick(get_area_turfs(pick(areas)))
			target_x = T.x
			target_y = T.y

		var/turf/plant_location = locate(target_x, target_y, Z_LEVEL_STATION)
		plant_location.AddComponent(/datum/component/minimap_marker/minimap, MAP_SYNDICATE, "nuclear_bomb_pin", 'icons/obj/minimap/minimap_markers.dmi', "[marker_name] Plant Site")

/datum/game_mode/nuclear/process()
	set background = 1
	if (!podbay_authed && ticker.round_elapsed_ticks >= 15 MINUTES)
		auth_computer.authorize()
		podbay_authed = TRUE
	..()
	return

var/syndicate_name = null
/proc/syndicate_name()
	if (syndicate_name)
		return syndicate_name

	var/name = ""

	// Prefix
#if defined(XMAS)
	name += pick("Merry", "Jingle", "Holiday", "Santa", "Gift", "Elf", "Jolly")
#elif defined(HALLOWEEN)
	name += pick("Hell", "Demon", "Blood", "Murder", "Gore", "Grave", "Sin", "Slaughter")
#else
	name += pick("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib", "Funk", "Joint", "Donk", "Elec")
#endif
	// Suffix
	if (prob(80))
		name += " "

		// Full
		if (prob(60))
			name += pick("Syndicate", "Consortium", "Collective", "Corporation", "Consolidated", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Family", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive", "Cartel", "Company")
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

/obj/cairngorm_stats/
	name = "\improper Mission Memorial"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "memorial_mid"
	anchored = ANCHORED
	opacity = 0
	density = 1

	New()
		..()
		var/wins = world.load_intra_round_value("nukie_win")
		var/losses = world.load_intra_round_value("nukie_loss")
		if(isnull(wins))
			wins = 0
		if(isnull(losses))
			losses = 0
		var/last_reset_date = world.load_intra_round_value("nukie_last_reset")
		var/last_reset_text = null
		if(!isnull(last_reset_date))
			var/days_passed = round((world.realtime - last_reset_date) / (1 DAY))
			last_reset_text = "<h4>(memorial reset [days_passed] days ago)</h4>"
		src.desc = "<center><h2><b>Battlecruiser Cairngorm Mission Memorial</b></h2><br> <h3>Successful missions: [wins]<br>\nUnsuccessful missions: [losses]</h3><br>[last_reset_text]</center>"

	attack_hand(var/mob/user)
		if (..(user))
			return

		tgui_message(user, src.desc, "Mission Memorial", theme = "syndicate")


/obj/New()
	. = ..()
	if(length(nuke_op_camo_matrix) && (src in by_cat[TR_CAT_NUKE_OP_STYLE]))
		src.color = color_mapping_matrix(nuke_op_color_matrix, nuke_op_camo_matrix)



/obj/cairngorm_stats/left
	icon_state = "memorial_left"

/obj/cairngorm_stats/right
	icon_state = "memorial_right"
#undef AMOUNT_OF_VALID_NUKE_PLANT_LOCATIONS
