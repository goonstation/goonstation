#define TEAM_NANOTRASEN 1
#define TEAM_SYNDICATE 2
#define TEAM_NEUTRAL 3

#define FORTUNA "FORTUNA"
#define RELIANT "RELIANT"
#define UVB67 "UVB67"
#define CHUCKS "CHUCKS"


#define PW_COMMANDER_DIES 1
#define PW_CRIT_SYSTEM_DESTORYED 2
#define PW_LOSE 3
#define PW_LOSING 4
#define PW_WIN 5
#define PW_ROUNDSTART 6
#define PW_OBJECTIVE_SECURED 7
// #define PW_OBJECTIVE_LOST_CHUCKS 8
// #define PW_OBJECTIVE_LOST_FORTUNA 9
// #define PW_OBJECTIVE_LOST_RELIANT 10
// #define PW_OBJECTIVE_LOST_UVB67 11

//idk if this is a good idea. I'm setting them in the game mode, they'll be useless outisde of it...
var/list/pw_rewards_tier1 = null
var/list/pw_rewards_tier2 = null
var/list/pw_rewards_tier3 = null

/datum/game_mode/pod_wars
	name = "Pod Wars (Beta)(only works if current map is pod_wars.dmm)"
	config_tag = "pod_wars"
	regular = FALSE
	votable = 1
	probability = 0 // Overridden by the server config. If you don't have access to that repo, keep it 0.
	crew_shortage_enabled = 0

	shuttle_available = SHUTTLE_AVAILABLE_DISABLED
	list/latejoin_antag_roles = list() // Unrecognized roles default to traitor in mob/new_player/proc/makebad().
	do_antag_random_spawns = 0
	do_random_events = 0
	escape_possible = 0
	var/list/frequencies_used = list()
	var/list/control_points = list()		//list of /datum/control_point
	var/datum/pw_stats_manager/stats_manager

	var/datum/pod_wars_team/team_NT
	var/datum/pod_wars_team/team_SY

	var/atom/movable/screen/hud/score_board/board
	var/round_limit = 45 MINUTES
	var/activate_control_points_time = 5 MINUTES
	var/round_start_time					//value of TIME macro at post_setup proc call. IDK if this value is stored somewhere already.
	var/did_ion_storm_happen = FALSE 		//set to true when the ion storm comes.

	var/force_end = 0
	var/slow_delivery_process = 0			//number of ticks to skip the extra gang process loops


/datum/game_mode/pod_wars/announce()
	boutput(world, "<B>The current game mode is - Pod Wars!</B>")
	boutput(world, "<B>Two starships of similar technology and crew compliment warped into the same asteroid field!</B>")
	boutput(world, "<B>Mine materials, build pods, kill enemies, destroy the enemy mothership!</B>")

//setup teams and commanders
/datum/game_mode/pod_wars/pre_setup()
	if (global.map_setting != "POD_WARS")
		message_admins("Pod wars gamemode attempted to start with a non pod wars map, aborting!")
		logTheThing(LOG_DEBUG, "Pod wars gamemode attempted to start with a non pod wars map, aborting!")
		return 0

	board = new()
	stats_manager = new()
	if (!setup_teams())
		return 0

	//just to move the bar to the right place.
	handle_point_change(team_NT, team_NT.points)	//HAX. am
	handle_point_change(team_SY, team_SY.points)	//HAX. am

	return 1


/datum/game_mode/pod_wars/proc/setup_teams()
	team_NT = new/datum/pod_wars_team(mode = src, team_num = TEAM_NANOTRASEN)
	team_SY = new/datum/pod_wars_team(mode = src, team_num = TEAM_SYNDICATE)

	//get all ready players and split em into two equal teams,
	var/list/readied_minds = list()
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue
		if (player.ready && player.mind)
			readied_minds += player.mind

	if (islist(readied_minds))
		var/length = length(readied_minds)
		shuffle_list(readied_minds)
		if (length < 2)
			if (prob(50))
				team_NT.accept_initial_players(readied_minds)
			else
				team_SY.accept_initial_players(readied_minds)

		else
			var/half = round(length/2)
			team_NT.accept_initial_players(readied_minds.Copy(1, half+1))
			team_SY.accept_initial_players(readied_minds.Copy(half+1, 0))

	return 1

// Refactor this when pod wars roles are refactored into special role datums.
/datum/game_mode/pod_wars/proc/setup_team_overlay(datum/mind/mind, overlay_icon_state)
	var/datum/client_image_group/antagonist_image_group = get_image_group(CLIENT_IMAGE_GROUP_ALL_ANTAGONISTS)
	var/datum/client_image_group/pod_wars_image_group = get_image_group(CLIENT_IMAGE_GROUP_POD_WARS)

	// Add the player's team overlay to the general antagonist overlay image group, for Admin purposes.
	if (antagonist_image_group.minds_with_associated_mob_image[mind])
		antagonist_image_group.remove_mind_mob_overlay(mind)
	var/image/antag_icon = image('icons/mob/antag_overlays.dmi', icon_state = overlay_icon_state)
	antag_icon.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	antagonist_image_group.add_mind_mob_overlay(mind, antag_icon)

	// Add the player's mind and their team overlay to the Pod Wars image group.
	if (!pod_wars_image_group.subscribed_minds_with_subcount[mind])
		pod_wars_image_group.add_mind(mind)

	if (pod_wars_image_group.minds_with_associated_mob_image[mind])
		pod_wars_image_group.remove_mind_mob_overlay(mind)
	var/image/pod_wars_icon = image('icons/mob/antag_overlays.dmi', icon_state = overlay_icon_state)
	pod_wars_icon.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	pod_wars_image_group.add_mind_mob_overlay(mind, pod_wars_icon)

/datum/game_mode/pod_wars/proc/add_latejoin_to_team(var/datum/mind/mind, var/datum/job/JOB)
	if (istype(JOB, /datum/job/special/pod_wars/nanotrasen))
		team_NT.members += mind
		team_NT.equip_player(mind.current, TRUE)
		get_latejoin_turf(mind, TEAM_NANOTRASEN)
	else if (istype(JOB, /datum/job/special/pod_wars/syndicate))
		team_SY.members += mind
		team_SY.equip_player(mind.current, TRUE)
		get_latejoin_turf(mind, TEAM_SYNDICATE)

//Loops through latejoin spots. Places you in the one that is on the correct base ship in accordance with your job.
/datum/game_mode/pod_wars/proc/get_latejoin_turf(var/datum/mind/mind, var/team_num)
#if defined(MAP_OVERRIDE_POD_WARS)
	for(var/turf/T in landmarks[LANDMARK_LATEJOIN])
		if (team_num == TEAM_NANOTRASEN && istype(T.loc, /area/pod_wars/team1))
			mind.current.set_loc(T)
			return
		else if (team_num == TEAM_SYNDICATE && istype(T.loc, /area/pod_wars/team2))
			mind.current.set_loc(T)
			return
#endif
// //search an area for a obj/control_point_computer, make the datum
// /datum/game_mode/pod_wars/proc/add_control_point(var/path, var/name)
// 	var/list/turfs = get_area_turfs(path, 1)
// 	for (var/turf/T in turfs)
// 		var/obj/control_point_computer/CPC = locate(/obj/control_point_computer) in T.contents
// 		if (CPC)
// 			var/datum/control_point/P = new/datum/control_point(CPC, get_area_by_type(path), name)
// 			CPC.ctrl_pt = P 	//computer's reference to datum
// 			control_points += P


/datum/game_mode/pod_wars/post_setup()
	//Setup Capture Points. We do it based on the Capture point computers. idk why. I don't have much time, and I'm tired.
	SPAWN(-1)
		//search each of these areas for the computer, then make the control_point datum from em.
		// add_control_point(/area/pod_wars/spacejunk/reliant, RELIANT)
		// add_control_point(/area/pod_wars/spacejunk/fstation, FORTUNA)
		// add_control_point(/area/pod_wars/spacejunk/uvb67, UVB67)

		setup_control_points()
		setup_critical_systems()
		setup_manufacturer_resources()

	SPAWN(-1)
		setup_asteroid_ores()

	round_start_time = TIME

	//setup rewards crate lists
	setup_pw_crate_lists()


	if(round_limit > 0)
		SPAWN(round_limit) // this has got to end soon
			command_alert("Something something radiation.","Emergency Update")
			sleep(10 MINUTES)
			command_alert("More radiation, too much...", "Emergency Update")
			sleep(5 MINUTES)
			command_alert("You may feel a slight burning sensation.", "Emergency Update")
			sleep(10 SECONDS)
			for(var/mob/living/carbon/M in mobs)
				M.emote("fart")
			force_end = 1

	src.playsound_to_team(team_NT, "sound/voice/pod_wars_voices/NanoTrasen-Roundstart{ALTS}.ogg", sound_type=PW_ROUNDSTART)
	src.playsound_to_team(team_SY, "sound/voice/pod_wars_voices/Syndicate-Roundstart{ALTS}.ogg", sound_type=PW_ROUNDSTART)

/datum/game_mode/pod_wars/proc/setup_manufacturer_resources()
	for_by_tcl(M, /obj/machinery/manufacturer/pod_wars)
		M.claim_free_resources(src)
	for_by_tcl(M, /obj/machinery/manufacturer/mining/pod_wars)
		M.claim_free_resources(src)

/datum/game_mode/pod_wars/proc/setup_critical_systems()
	for (var/obj/pod_base_critical_system/sys in world)
		switch(sys.team_num)
			if (TEAM_NANOTRASEN)
				team_NT.mcguffins += sys
			if (TEAM_SYNDICATE)
				team_SY.mcguffins += sys


/datum/game_mode/pod_wars/proc/setup_control_points()
	//hacky way. lame, but fast (for me). What else is going on in the post_setup anyway?
	for (var/obj/control_point_computer/CPC in world)
		var/area/A = get_area(CPC)
		var/name = ""
		var/true_name = ""
		if (istype(A, /area/pod_wars/spacejunk/reliant))
			name = "The NSV Reliant"
			true_name = RELIANT
			CPC.update_name_overlay("reliant")
		else if (istype(A, /area/pod_wars/spacejunk/fstation))
			name = "Fortuna Station"
			true_name = FORTUNA
			CPC.update_name_overlay("fortuna")
		else if (istype(A, /area/pod_wars/spacejunk/uvb67))
			name = "UVB-67"
			true_name = UVB67
			CPC.update_name_overlay("uvb")
		var/datum/control_point/P = new/datum/control_point(CPC, A, name, true_name, src)

		CPC.ctrl_pt = P 		//computer's reference to datum
		control_points += P 	//game_mode's reference to the point


/datum/game_mode/pod_wars/proc/setup_asteroid_ores()

//	var/list/types = list("mauxite", "pharosium", "molitz", "char", "ice", "cobryl", "bohrum", "claretine", "viscerite", "koshmarite", "syreline", "gold", "plasmastone", "cerenkite", "miraclium", "nanite cluster", "erebite", "starstone")
//	var/list/weights = list(100, 100, 100, 125, 55, 55, 25, 25, 55, 40, 20, 20, 15, 20, 10, 1, 5, 2)

	var/datum/ore_cluster/minor/minor_ores = new /datum/ore_cluster/minor
	for(var/area/pod_wars/asteroid/minor/A in world)
		if(!istype(A, /area/pod_wars/asteroid/minor/nospawn))
			for(var/turf/simulated/wall/auto/asteroid/pod_wars/AST in A)
				//Do the ore_picking
				AST.randomize_ore(minor_ores)

	var/list/datum/ore_cluster/oreClusts = list()
	for(var/OC in concrete_typesof(/datum/ore_cluster))
		oreClusts += new OC

	for(var/area/pod_wars/asteroid/major/A in world)
		var/datum/ore_cluster/OC = pick(oreClusts)
		OC.quantity -= 1
		if(OC.quantity <= 0) oreClusts -= OC
		//oreClusts -= OC
		for(var/turf/simulated/wall/auto/asteroid/pod_wars/AST in A)
			if(prob(OC.fillerprob))
				AST.randomize_ore(minor_ores)
			else
				AST.randomize_ore(OC)
			AST.hardness += OC.hardness_mod
	return 1

//////////////////
///////////////pod_wars asteroids
/turf/simulated/wall/auto/asteroid/pod_wars
	name = "asteroid"
	desc = "It's asteroid material."
	hardness = 1
	default_ore = /obj/item/raw_material/rock

	// varied layers

	New()
		..()

	//Don't think this can go in new.
	proc/randomize_ore(var/datum/ore_cluster/OC)
		if(!prob(OC.density)) return

		var/ore_name
		ore_name = weighted_pick(OC.ore_types + (((length(OC.hiddenores) && !(locate(/turf/space) in range(1, src)))) ? OC.hiddenores : list()))

		//stolen from Turfspawn_Asteroid_SeedSpecificOre
		var/datum/ore/O = mining_controls?.get_ore_from_string(ore_name)
		src.ore = O
		src.hardness += O.hardness_mod
		src.amount = rand(O.amount_per_tile_min,O.amount_per_tile_max)
		var/image/ore_overlay = image('icons/turf/walls/asteroid.dmi',"[O.name][src.orenumber]")
		ore_overlay.filters += filter(type="alpha", icon=icon('icons/turf/walls/asteroid.dmi',"mask-side_[src.icon_state]"))
		ore_overlay.layer = ASTEROID_ORE_OVERLAY_LAYER  // so meson goggle nerds can still nerd away

		src.UpdateOverlays(ore_overlay, "ast_ore")

		if(prob(OC.gem_prob))
			add_event(/datum/ore/event/gem, O)

	proc/add_event(var/list/datum/ore/event/new_event, var/datum/ore/O)
		var/datum/ore/event/E = new new_event
		E.set_up(O)
		src.set_event(E)

ABSTRACT_TYPE(/datum/ore_cluster)
/datum/ore_cluster
	var/list/ore_types
	var/density = 40
	var/hardness_mod = 0
	var/list/hiddenores
	var/quantity = 1
	var/fillerprob = 0
	var/gem_prob = 0

	minor
		ore_types = list("mauxite" = 100, "pharosium" = 100, "molitz" = 100, "char" = 125, "ice" = 55, "cobryl" = 55, "bohrum" = 25, "claretine" = 25, "viscerite" = 55, "koshmarite" = 40, "syreline" = 20, "gold" = 20, "plasmastone" = 15, "cerenkite" = 20, "miraclium" = 10, "nanite cluster" = 1, "erebite" = 5, "starstone" = 2)
		quantity = 15
		gem_prob = 10

	pharosium
		ore_types = list("pharosium" = 100, "gold" = 5)
		quantity = 2
		fillerprob = 10

	starstone
		ore_types = list( "char" = 95)
		hiddenores = list("starstone" = 5)
		density = 40
		hardness_mod = 3

	metal
		ore_types = list("mauxite" = 100, "cobryl" = 30, "bohrum" = 50, "syreline" = 10, "gold" = 5, "pharosium" = 20)
		hiddenores = list("nanite cluster" = 2)
		quantity = 10
		fillerprob = 5

	rads
		ore_types = list("cerenkite" = 50, "plasmastone" = 40)
		hiddenores = list("erebite" = 10)
		density = 40
		quantity = 2

	shitty_comet
		ore_types = list("ice" = 100)
		hiddenores = list("miraclium" = 100)
		density = 50
		quantity = 2

	crystal
		ore_types = list("molitz" = 100, "plasmastone" = 10)
		hiddenores = list("erebite" = 1)
		gem_prob = 5
		quantity = 3

//for testing, can remove when sure this works - Kyle
/datum/game_mode/pod_wars/proc/test_point_change(var/team as num, var/amt as num)

	if (team == TEAM_NANOTRASEN)
		team_NT.points = amt
		handle_point_change(team_NT)
	else if (team == TEAM_SYNDICATE)
		team_SY.points = amt
		handle_point_change(team_SY)

//handles what happens when the a control point is captured by a team
//true_name = name of the point captured
//user = who did the capturing? //might remove later if I change the capture system
//team = the team datum
//team_num = 1 or 2 for NT or SY respectively
/datum/game_mode/pod_wars/proc/handle_control_point_change(var/datum/control_point/point, var/mob/user, var/datum/pod_wars_team/team)
	var/team_num = team.team_num
	board.change_control_point_owner(point.true_name, team_num)

	var/team_string = "[team_num == 1 ? "NanoTrasen" : team_num == 2 ? "The Syndicate" : "Something Eldritch"]"
	boutput(world, "<h4><span class='[team_num == 1 ? "notice":"alert"]'>[user] has captured [point.true_name] for [team_string]!</span></h4>")


	switch(team_num)
		if (TEAM_NANOTRASEN)
			src.playsound_to_team(team_NT, "sound/voice/pod_wars_voices/{PWTN}Objective_Secured{ALTS}.ogg", 60, sound_type=PW_OBJECTIVE_SECURED)
			src.playsound_to_team(team_SY, "sound/voice/pod_wars_voices/{PWTN}Objective_Lost_[point.true_name]{ALTS}.ogg", 60, sound_type=point.true_name)

		if (TEAM_SYNDICATE)
			src.playsound_to_team(team_SY, "sound/voice/pod_wars_voices/{PWTN}Objective_Secured{ALTS}.ogg", 60, sound_type=PW_OBJECTIVE_SECURED)
			src.playsound_to_team(team_NT, "sound/voice/pod_wars_voices/{PWTN}Objective_Lost_[point.true_name]{ALTS}.ogg", 60, sound_type=point.true_name)

/datum/game_mode/pod_wars/proc/handle_point_change(var/datum/pod_wars_team/team)
	var/fraction = round (team.points/team.max_points, 0.01)
	fraction = clamp(fraction, 0, 0.99)


	var/matrix/M1 = matrix()
	M1.Scale(fraction, 1)
	var/offset = round(-64+fraction * 64, 1)
	offset ++

	if (team == team_NT)
		board?.bar_NT.points = team.points
		animate(board.bar_NT, transform = M1, pixel_x = offset, time = 10)
	else
		board?.bar_SY.points = team.points
		animate(board.bar_SY, transform = M1, pixel_x = offset, time = 10)

//check which team they are on and iff they are a commander for said team. Deduct/award points
//Oh man, this is fucking bad. Before I had my "system" set up where I just check for the mind.special_role,
//I should fix this soon, but it works good enough for now... -kyle 4/20/21
/datum/game_mode/pod_wars/on_human_death(var/mob/M)
	src.stats_manager?.inc_death(M)

	switch(get_pod_wars_team_num(M))
		if (TEAM_NANOTRASEN)
			do_team_member_death(M, team_NT, team_SY)
		if (TEAM_SYNDICATE)
			do_team_member_death(M, team_SY, team_NT)

	..()

/datum/game_mode/pod_wars/proc/do_team_member_death(var/mob/M, var/datum/pod_wars_team/our_team, var/datum/pod_wars_team/enemy_team)
	our_team.change_points(-0.5)
	var/nt_death = world.load_intra_round_value("nt_death")
	var/sy_death = world.load_intra_round_value("sy_death")
	if(isnull(nt_death))
		nt_death = 0
	if(isnull(sy_death))
		sy_death = 0
	if (get_pod_wars_team_num(M) == TEAM_NANOTRASEN)
		world.save_intra_round_value("nt_death", nt_death + 1)
	if (get_pod_wars_team_num(M) == TEAM_SYNDICATE)
		world.save_intra_round_value("sy_death", sy_death + 1)
	if (M.mind == our_team.commander)
		our_team.change_points(-2)
		if (get_pod_wars_team_num(M) == TEAM_NANOTRASEN)
			world.save_intra_round_value("nt_death", nt_death + 1)
		if (get_pod_wars_team_num(M) == TEAM_SYNDICATE)
			world.save_intra_round_value("sy_death", sy_death + 1)
		if (!our_team.first_commander_death)
			our_team.first_commander_death = 1
			src.playsound_to_team(our_team, "sound/voice/pod_wars_voices/{PWTN}Commander_Dies{ALTS}.ogg", sound_type=PW_COMMANDER_DIES)
	enemy_team.change_points(1)

/datum/game_mode/pod_wars/proc/announce_critical_system_destruction(var/team_num, var/obj/pod_base_critical_system/CS)
	var/datum/pod_wars_team/team
	switch(team_num)
		if (TEAM_NANOTRASEN)
			team = team_NT
		if (TEAM_SYNDICATE)
			team = team_SY

	team.change_points(-25)

	//If it's the first one for this team, play the voice line, otherwise play the ship alert sound.
	if (!team.first_system_destroyed)
		team.first_system_destroyed = 1
		src.playsound_to_team(team, "sound/voice/pod_wars_voices/{PWTN}Crit_System_Destroyed{ALTS}.ogg", sound_type=PW_CRIT_SYSTEM_DESTORYED)
	else
		src.playsound_to_team(team, 'sound/effects/ship_alert_major.ogg', 60)

	//Gah, why? Gotta say "The" I guess.
	var/team_name_string = team?.name
	if (team.team_num == TEAM_SYNDICATE)
		team_name_string = "The Syndicate"
	boutput(world, SPAN_ALERT("<h3>[team_name_string]'s [CS] has been destroyed!!</h3>"))

	//if all of this team's crit systems have been destroyed, atomatically end the round...
	if (!length(team.mcguffins))
		team.change_points(-300)

/datum/game_mode/pod_wars/proc/announce_critical_system_damage(var/team_num, var/obj/pod_base_critical_system/CS)
	var/datum/pod_wars_team/team
	switch (team_num)
		if (TEAM_NANOTRASEN)
			team = team_NT
		if (TEAM_SYNDICATE)
			team = team_SY

	src.playsound_to_team(team, 'sound/effects/ship_alert_minor.ogg')
	var/team_name_string = team?.name
	if (team.team_num == TEAM_SYNDICATE)
		team_name_string = "The Syndicate"
	boutput(world, SPAN_ALERT("<h3>[team_name_string]'s [CS] is under attack!!</h3>"))


/datum/game_mode/pod_wars/check_finished()
	if (force_end)
		return 1
	if (team_NT.points <= 0 || team_SY.points <= 0)
		return 1
	if (team_NT.points > team_NT.max_points || team_SY.points > team_SY.max_points)
		return 1

 return 0

/datum/game_mode/pod_wars/process()
	..()
	slow_delivery_process ++
	if (slow_delivery_process >= 60)
		slow_delivery_process = 0
		src.handle_control_point_rewards()


	//ion storm once then never again
	if (!did_ion_storm_happen && round_start_time + activate_control_points_time < TIME)
		did_ion_storm_happen = TRUE
		command_alert("An extremely powerful ion storm has reached this system! <b>Control Point Computers at Fortuna, the Reliant, and UVB-67</b> are now active! Both NanoTrasen and Syndicate <b>Pod Carriers' shields are down!</b>","Control Point Computers Online")
		//stolen from blowout.
		var/sound/siren = sound('sound/misc/airraid_loop.ogg')
		siren.repeat = FALSE
		siren.channel = 5
		siren.volume = 50
		world << siren

		for (var/datum/control_point/P in src.control_points)
			P?.computer.can_be_captured = 1

		//for loop through crit systems for each team
		for (var/obj/pod_base_critical_system/sys in team_NT.mcguffins)
			sys.shielded = 0
		for (var/obj/pod_base_critical_system/sys in team_SY.mcguffins)
			sys.shielded = 0

/datum/game_mode/pod_wars/proc/handle_control_point_rewards()

	for (var/datum/control_point/P in src.control_points)
		// message_admins("[P.name]-owner=[P.owner_team]-tier=[P.crate_rewards_tier]")
		P.do_item_delivery()

/datum/game_mode/pod_wars/declare_completion()
	var/datum/pod_wars_team/winner
	var/datum/pod_wars_team/loser

	if (team_NT.points >= team_SY.points)		//Gotta have a winner for now... idk
		winner = team_NT
		loser = team_SY
	else
		winner = team_SY
		loser = team_NT

	if(winner == team_NT) //putting this in a seperate code block for cleanliness
		var/value = world.load_intra_round_value("nt_win")
		if(isnull(value))
			value = 0
		world.save_intra_round_value("nt_win", value + 1)
	else if(winner == team_SY)
		var/value = world.load_intra_round_value("sy_win")
		if(isnull(value))
			value = 0
		world.save_intra_round_value("sy_win", value + 1)

	// var/text = ""
	boutput(world, "<FONT size = 3><B>The winner was the [winner.name], commanded by [winner.commander?.current] ([winner.commander?.current?.ckey]):</B></FONT><br>")
	output_team_members(winner)

	boutput(world, "<FONT size = 3><B>The loser was the [loser.name], commanded by [loser.commander?.current] ([loser.commander?.current?.ckey]):</B></FONT><br>")
	output_team_members(loser)


	src.playsound_to_team(winner, "sound/voice/pod_wars_voices/{PWTN}Win{ALTS}.ogg", sound_type=PW_WIN)
	src.playsound_to_team(loser, "sound/voice/pod_wars_voices/{PWTN}Lose{ALTS}.ogg", sound_type=PW_LOSE)

	// output the player stats on its own popup.
	stats_manager.display_HTML_to_clients()
	..()

//Plays a sound for a particular team.
//pw_team can be the team datum or TEAM_NANOTRASEN|TEAM_SYNDICATE
//filepath; sound file path as a string.
/datum/game_mode/pod_wars/proc/playsound_to_team(var/pw_team, var/filepath, var/volume = 75, var/sound_type = 0)
	if (isnull(pw_team) || isnull(filepath))
		return 0
	var/datum/pod_wars_team/team = null
	//If pw_team is a num, make team a one of the pod_wars_team
	if (isnum(pw_team))
		switch(pw_team)
			if (TEAM_NANOTRASEN)
				team = team_NT
			if (TEAM_SYNDICATE)
				team = team_SY
	//handle if we are given a datum of type /datum/pod_wars_team/team
	else if (istype(pw_team, /datum/pod_wars_team))
		team = pw_team
	//error handling...
	else
		logTheThing(LOG_DEBUG, null, "Something went wrong trying to play a sound for a team=[team]|[pw_team].!!!")
		message_admins("Something went wrong trying to play a sound for a team")
		return 0

	//use the format of sound files in /sound/voice/pod_wars_voices.
	//If we find "{PWTN}" in the filepath, then we replace that with the team name, either "NanoTrasen"- or "Syndicate-"?
	//{PWTN} = PodWarsTeamName
	if (findtext(filepath, "{PWTN}"))
		filepath = replacetext(filepath, "{PWTN}", "[team.name]-")

	var/sound_amts = get_voice_line_alts_for_team_sound(team, sound_type)
	if (sound_amts && findtext(filepath, "{ALTS}"))
		filepath = replacetext(filepath, "{ALTS}", "-[rand(1, sound_amts)]")	//if alts is 1, it rand(1,1) will always choose 1

	//uncomment this message_admins for testing sounds
	// message_admins("playing to:[team.name]. filepath is now: [filepath]")
	for (var/datum/mind/M in team.members)
		M.current.playsound_local(M.current, filepath, volume, 0, flags = SOUND_IGNORE_SPACE)

	return 1

//get the amount of alt lines we have for each type of voice line based on the define added...
datum/game_mode/pod_wars/proc/get_voice_line_alts_for_team_sound(var/datum/pod_wars_team/team, var/sound_type)
	switch(sound_type)
		if (PW_COMMANDER_DIES)
			return team.sl_amt_commander_dies
		if (PW_CRIT_SYSTEM_DESTORYED)
			return team.sl_amt_crit_system_destroyed
		if (PW_LOSE)
			return team.sl_amt_lose
		if (PW_LOSING)
			return team.sl_amt_losing
		if (PW_WIN)
			return team.sl_amt_win
		if (PW_ROUNDSTART)
			return team.sl_amt_roundstart
		if (PW_OBJECTIVE_SECURED)
			return team.sl_amt_objective_secured
		if (CHUCKS)
			return team.sl_amt_objective_lost_chucks
		if (FORTUNA)
			return team.sl_amt_objective_lost_fortuna
		if (RELIANT)
			return team.sl_amt_objective_lost_reliant
		if (UVB67)
			return team.sl_amt_objective_lost_uvb67
	return 0

//outputs the team members to world for declare_completion
/datum/game_mode/pod_wars/proc/output_team_members(var/datum/pod_wars_team/pw_team)
	var/string = ""
	var/active_players = 0
	for (var/datum/mind/m in pw_team.members)
		if (m.current?.ckey)
			active_players ++
		if (m == pw_team.commander)
			continue 		//count em for active players, but don't display em here, they already got their name up there!
		string += "<b>[m.current]</b> ([m.ckey])</b><br>"
	boutput(world, "<h3 class='admin'>[active_players] active players/[length(pw_team.members)] total players.</h3>")



//////////////////SCOREBOARD STUFF//////////////////
//only the board really need to be a hud.  I guess the others could too, but it doesn't matter.
/atom/movable/screen/hud/score_board
	name = "Score"
	desc = ""
	icon = 'icons/misc/128x32.dmi'
	icon_state = "pw_backboard"
	screen_loc = "NORTH, CENTER"
	var/atom/movable/screen/border = null
	var/atom/movable/screen/pw_score_bar/bar_NT = null
	var/atom/movable/screen/pw_score_bar/bar_SY = null

	var/list/control_points

	var/theme = null
	alpha = 150

	//builds all the pieces and adds em to the score_board whose sprite is the backboard
	New()
		..()
		border = new(src)
		border.name = "border"
		border.icon = icon
		border.icon_state = "pw_border"
		border.vis_flags = VIS_INHERIT_ID

		create_and_add_hud_objects()

	proc/create_and_add_hud_objects()
		//Score Points bars
		bar_NT = new /atom/movable/screen/pw_score_bar/nt(src)
		bar_SY = new /atom/movable/screen/pw_score_bar/sy(src)

		//Control Points creation and adding to list
		control_points = list()
		control_points.Add(new/atom/movable/screen/control_point/uvb67())
		control_points.Add(new/atom/movable/screen/control_point/reliant())
		control_points.Add(new/atom/movable/screen/control_point/fortuna())

		//add em all to vis_contents
		src.vis_contents += bar_NT
		src.vis_contents += bar_SY
		src.vis_contents += border

		for (var/atom/movable/screen/S in control_points)
			src.vis_contents += S

	///takes the control point screen object's true_name var and the team_num of the new owner: NT=1, SY=2
	proc/change_control_point_owner(var/true_name, var/team_num)

		for (var/atom/movable/screen/control_point/C in control_points)
			if (true_name == C.true_name)
				C.change_color(team_num)
				break;	//Only ever gonna be one of em.


	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder && control == "mapwindow.map")
			var/theme = src.theme

			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = src.name,
				"content" = "NT Points: [bar_NT.points]\n SY Points: [bar_SY.points]",
				"theme" = theme
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

/atom/movable/screen/pw_score_bar
	icon = 'icons/misc/128x32.dmi'
	desc = ""
	vis_flags = VIS_INHERIT_ID
	var/points = 50
	// var/max_points = 100		//unused I think.

/atom/movable/screen/pw_score_bar/nt
	name = "NanoTrasen Points"
	icon_state = "pw_nt"

/atom/movable/screen/pw_score_bar/sy
	name = "Syndicate Points"
	icon_state = "pw_sy"

//displays the owner of the capture point based on colour
/atom/movable/screen/control_point
	name = "Score"
	desc = ""
	icon = 'icons/ui/context16x16.dmi'		//re-appropriating this solid circle sprite from here
	icon_state = "key_special1"
	screen_loc = "NORTH, CENTER"
	pixel_y = 8
	var/true_name = null 		//backend name, var/name is the human readable name

	///team, neutral = 0, NT = 1, SY = 2
	proc/change_color(var/team)
		//Colours kinda off, but I wanted em to stand out against the background.
		switch(team)
			if (TEAM_NANOTRASEN)
				color = "#004EFF"
			if (TEAM_SYNDICATE)
				color = "#FF004E"
			else
				color = null

	//You might be asking yourself "What are all these random pixel_x values?" They are the pixel coords ~ 1/4, 1/2, and 3/4
	//accross the bar. Then you might ask, "Why didn't you just divide by the length of the bar?" Of course I tried that, but I couldn't
	//fucking FIND that value. Why does that not exist? it seems like it should, after all, the mouse knows the bounds? Well, I don't know.

	//left
	uvb67
		name = "UVB-67"
		true_name = UVB67
		pixel_x = 25

		screen_loc = "NORTH, CENTER-1:-16"

	//center
	reliant
		name = "NSV Reliant"
		true_name = RELIANT
		pixel_x = 57
		screen_loc = "NORTH, CENTER"

	//right
	fortuna
		name = "Fortuna Station"
		true_name = FORTUNA
		screen_loc = "NORTH, CENTER-1:16"
		pixel_x = 91

/////////////END of SCOREBOARD STUFF//////////////////////////////
//////////////////////////////////////////////////

//emergency Fabs

ABSTRACT_TYPE(/obj/machinery/macrofab/pod_wars)
/obj/machinery/macrofab/pod_wars
	name = "Emergency Combat Pod Fabricator"
	desc = "A sophisticated machine that fabricates short-range emergency pods from a nearby reserve of supplies."
	createdObject = /obj/machinery/vehicle/arrival_pod
	itemName = "emergency pod"
	sound_volume = 15
	var/team_num = 0


	attack_hand(var/mob/user)
		if (get_pod_wars_team_num(user) != team_num)
			boutput(user, SPAN_ALERT("This machine's design makes no sense to you, you can't figure out how to use it!"))
			return

		..()

	nanotrasen
		createdObject = /obj/machinery/vehicle/pod_wars_dingy/nanotrasen
		team_num = 1

		mining
			name = "Emergency Mining Pod Fabricator"
			createdObject = /obj/machinery/vehicle/pod_wars_dingy/nanotrasen/mining


	syndicate
		createdObject = /obj/machinery/vehicle/pod_wars_dingy/syndicate
		team_num = 2

		mining
			name = "Emergency Mining Pod Fabricator"
			createdObject = /obj/machinery/vehicle/pod_wars_dingy/syndicate/mining

ABSTRACT_TYPE(/obj/machinery/vehicle/pod_wars_dingy)
/obj/machinery/vehicle/pod_wars_dingy
	name = "Pod"
	icon = 'icons/obj/ship.dmi'
	icon_state = "pod"
	capacity = 1
	health = 100
	maxhealth = 100
	anchored = UNANCHORED
	var/weapon_type = /obj/item/shipcomponent/mainweapon/phaser/short
	speedmod = 0.59

	New()
		..()
		/obj/item/shipcomponent/mainweapon/phaser/short

		src.m_w_system = new weapon_type( src )
		src.m_w_system.ship = src
		src.components += src.m_w_system

		src.lock = new /obj/item/shipcomponent/secondary_system/lock/pw_id( src )
		src.lock.ship = src
		src.components += src.lock

		myhud.update_systems()
		myhud.update_states()
		return



	proc/equip_mining()
		// src.sensors = new /obj/item/shipcomponent/sensor/mining( src )
		// src.sensors.ship = src
		// src.components += src.sensors

		src.sec_system = new /obj/item/shipcomponent/secondary_system/orescoop( src )
		src.sec_system.ship = src
		src.components += src.sec_system


	nanotrasen
		name = "NT Combat Dingy"
		icon_state = "putt_pre"
		init_comms_type = /obj/item/shipcomponent/communications/security

		mining
			name = "NT Mining Dingy"
			weapon_type = /obj/item/shipcomponent/mainweapon/bad_mining

			New()
				..()
				equip_mining()

	syndicate
		name = "Syndicate Combat Dingy"
		icon_state = "syndiputt"
		init_comms_type = /obj/item/shipcomponent/communications/syndicate

		mining
			name = "Syndicate Mining Dingy"
			weapon_type = /obj/item/shipcomponent/mainweapon/bad_mining

			New()
				equip_mining()
				..()



/////////////////////////////////////////////////
///////////////////ABILITY HOLDER////////////////
/////////////////////////////////////////////////

//stole this from vampire. prevents runtimes. IDK why this isn't in the parent.
/atom/movable/screen/ability/topBar/pod_pilot
	clicked(params)
		var/datum/targetable/pod_pilot/spell = owner
		var/datum/abilityHolder/holder = owner.holder

		if (!istype(spell))
			return
		if (!spell.holder)
			return

		if(params["shift"] && params["ctrl"])
			if(owner.waiting_for_hotkey)
				holder.cancel_action_binding()
				return
			else
				owner.waiting_for_hotkey = 1
				src.UpdateIcon()
				boutput(usr, SPAN_NOTICE("Please press a number to bind this ability to..."))
				return

		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, SPAN_ALERT("You can't use this spell here."))
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()
		return



//return 1 for NT, 2 for SY
/proc/get_pod_wars_team_num(var/mob/user)
	var/user_team_string = user?.mind?.special_role
	switch (user_team_string)
		if ("NanoTrasen")
			return TEAM_NANOTRASEN
		if ("Syndicate")
			return TEAM_SYNDICATE
		else
			return 0


//this is global so admins can run this proc to spawn the crates if they like, idk why they'd really want to but might as well be safe.
//The list here is set up where the object path is the key, and the value is its point amount
proc/setup_pw_crate_lists()
	pw_rewards_tier1 = list(/obj/item/storage/firstaid/regular = 1, /obj/item/reagent_containers/mender/both = 1, 	///obj/item/tank/plasma = 2
		/obj/item/tank/oxygen = 1, /obj/item/storage/box/energy_frag = 4, /obj/item/storage/box/energy_concussion = 4, /obj/item/device/flash = 2, /obj/item/deployer/barricade = 4,
		/obj/item/shipcomponent/mainweapon/taser = 3, /obj/item/shipcomponent/mainweapon/laser/short = 3,/obj/item/ammo/power_cell/high_power = 5,
		/obj/item/material_piece/steel{amount=10} = 1, /obj/item/material_piece/copper{amount=10} = 1, /obj/item/material_piece/glass{amount=10} = 1)

	pw_rewards_tier2 = list(/obj/item/tank/jetpack = 1, /obj/item/old_grenade/smoke = 2,/obj/item/chem_grenade/flashbang = 2, /obj/item/barrier = 1,
		/obj/item/old_grenade/emp = 3, /obj/item/sword/discount = 4, /obj/item/storage/firstaid/crit = 1, /obj/item/fireaxe = 1, /obj/item/dagger/specialist = 2,
		/obj/item/shipcomponent/mainweapon/mining = 2, /obj/item/shipcomponent/mainweapon/laser = 4, /obj/item/shipcomponent/mainweapon/disruptor_light = 4,/obj/item/ammo/power_cell/higher_power = 3, /obj/item/ammo/power_cell/self_charging/pod_wars_standard = 3,
		/obj/item/material_piece/cerenkite{amount=5} = 1, /obj/item/material_piece/claretine{amount=5} = 1, /obj/item/material_piece/bohrum{amount=10} = 1, /obj/item/material_piece/plasmastone{amount=10} = 1, /obj/item/material_piece/uqill{amount=10} = 1, /obj/item/material_piece/telecrystal{amount=10})

	pw_rewards_tier3 = list(/obj/item/gun/energy/crossbow = 1, /obj/item/device/chameleon = 1,
		/obj/item/gun/flamethrower/backtank/napalm = 3, /obj/item/ammo/power_cell/self_charging/pod_wars_high = 2,
		/obj/item/shipcomponent/mainweapon/russian = 3, /obj/item/shipcomponent/mainweapon/disruptor = 3, /obj/item/shipcomponent/mainweapon/laser_ass = 4, /obj/item/shipcomponent/mainweapon/rockdrills = 4,
		/obj/item/material_piece/iridiumalloy{amount=4} = 1, /obj/item/material_piece/erebite{amount=10} = 1, /obj/item/raw_material/starstone{amount=2} = 1, /obj/item/raw_material/miracle{amount=10} = 1)


/proc/make_fake_explosion(var/atom/I)
	var/obj/overlay/O = new/obj/overlay(get_turf(I))
	O.anchored = ANCHORED
	O.name = "Explosion"
	O.layer = NOLIGHT_EFFECTS_LAYER_BASE
	O.pixel_x = -92
	O.pixel_y = -96
	O.icon = 'icons/effects/214x246.dmi'
	O.icon_state = "explosion"
	SPAWN(3.5 SECONDS)
		qdel(O)

/obj/decoration/memorial
	name = "Generic Memorial"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "memorial_mid"
	anchored = ANCHORED
	opacity = 0
	density = 1

/obj/decoration/memorial/pod_war_stats_nt/
	name = "Nanotrasen Mission Log"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "memorial_mid"
	anchored = ANCHORED
	opacity = 0
	density = 1



	New()
		..()
		var/nt_wins = world.load_intra_round_value("nt_win")
		var/nt_deaths = world.load_intra_round_value("nt_death")
		if(isnull(nt_wins))
			nt_wins = 0
		if(isnull(nt_deaths))
			nt_deaths = 0
		var/last_reset_date = world.load_intra_round_value("pod_wars_last_reset")
		var/last_reset_text = null
		if(!isnull(last_reset_date))
			var/days_passed = round((world.realtime - last_reset_date) / (1 DAY))
			last_reset_text = "<h4>(mission log reset [days_passed] days ago)</h4>"
		src.desc = "<center><h2><b>Pod Wars Mission Log</b></h2><br> <h3>Nanotrasen Victories: [nt_wins]<br>\nNanotrasen Deaths: [nt_deaths]</h3><br>[last_reset_text]</center>"

	attack_hand(var/mob/user)
		if (..(user))
			return

		tgui_message(user, src.desc, "Mission Log", theme = "ntos")

/obj/decoration/memorial/pod_war_stats_sy/
	name = "Syndicate Mission Log"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "memorial_mid"

	New()
		..()
		var/sy_wins = world.load_intra_round_value("sy_win")
		var/sy_deaths = world.load_intra_round_value("sy_death")
		if(isnull(sy_wins))
			sy_wins = 0
		if(isnull(sy_deaths))
			sy_deaths = 0
		var/last_reset_date = world.load_intra_round_value("pod_wars_last_reset")
		var/last_reset_text = null
		if(!isnull(last_reset_date))
			var/days_passed = round((world.realtime - last_reset_date) / (1 DAY))
			last_reset_text = "<h4>(mission log reset [days_passed] days ago)</h4>"
		src.desc = "<center><h2><b>Pod Wars Mission Log</b></h2><br> <h3>Syndicate Victories: [sy_wins]<br>\nSyndicate Deaths: [sy_deaths]</h3><br>[last_reset_text]</center>"

	attack_hand(var/mob/user)
		if (..(user))
			return

		tgui_message(user, src.desc, "Mission Log", theme = "syndicate")

/obj/decoration/memorial/memorial_left
	name = "Memorial Inscription"
	desc = "A memorial to those dead, but not forgotten."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "memorial_left"

/obj/decoration/memorial/memorial_right
	name = "Memorial Inscription"
	desc = "A memorial to those dead, but not forgotten."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "memorial_right"

#undef PW_COMMANDER_DIES
#undef PW_CRIT_SYSTEM_DESTORYED
#undef PW_LOSE
#undef PW_LOSING
#undef PW_WIN
#undef PW_ROUNDSTART
#undef PW_OBJECTIVE_SECURED
// #undef PW_OBJECTIVE_LOST_CHUCKS
// #undef PW_OBJECTIVE_LOST_FORTUNA
// #undef PW_OBJECTIVE_LOST_RELIANT
// #undef PW_OBJECTIVE_LOST_UVB67
