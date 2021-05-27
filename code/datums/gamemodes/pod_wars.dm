#define TEAM_NANOTRASEN 1
#define TEAM_SYNDICATE 2

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
	name = "pod wars"
	config_tag = "pod_wars"
	votable = 1
	probability = 0 // Overridden by the server config. If you don't have access to that repo, keep it 0.
	crew_shortage_enabled = 0

	shuttle_available = 0 // 0: Won't dock. | 1: Normal. | 2: Won't dock if called too early.
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
	var/round_limit = 70 MINUTES
	var/activate_control_points_time = 15 MINUTES
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
	SPAWN_DBG(-1)
		//search each of these areas for the computer, then make the control_point datum from em.
		// add_control_point(/area/pod_wars/spacejunk/reliant, RELIANT)
		// add_control_point(/area/pod_wars/spacejunk/fstation, FORTUNA)
		// add_control_point(/area/pod_wars/spacejunk/uvb67, UVB67)

		setup_control_points()
		setup_critical_systems()

	SPAWN_DBG(-1)
		setup_asteroid_ores()

	round_start_time = TIME

	//setup rewards crate lists
	setup_pw_crate_lists()


	if(round_limit > 0)
		SPAWN_DBG (round_limit) // this has got to end soon
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
		else if (istype(A, /area/pod_wars/spacejunk/fstation))
			name = "Fortuna Station"
			true_name = FORTUNA
		else if (istype(A, /area/pod_wars/spacejunk/uvb67))
			name = "UVB-67"
			true_name = UVB67
		var/datum/control_point/P = new/datum/control_point(CPC, A, name, true_name, src)

		CPC.ctrl_pt = P 		//computer's reference to datum
		control_points += P 	//game_mode's reference to the point


/datum/game_mode/pod_wars/proc/setup_asteroid_ores()

//	var/list/types = list("mauxite", "pharosium", "molitz", "char", "ice", "cobryl", "bohrum", "claretine", "viscerite", "koshmarite", "syreline", "gold", "plasmastone", "cerenkite", "miraclium", "nanite cluster", "erebite", "starstone")
//	var/list/weights = list(100, 100, 100, 125, 55, 55, 25, 25, 55, 40, 20, 20, 15, 20, 10, 1, 5, 2)

	var/datum/ore_cluster/minor/minor_ores = new /datum/ore_cluster/minor
	for(var/area/pod_wars/asteroid/minor/A in world)
		if(!istype(A, /area/pod_wars/asteroid/minor/nospawn))
			for(var/turf/simulated/wall/asteroid/pod_wars/AST in A)
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
		for(var/turf/simulated/wall/asteroid/pod_wars/AST in A)
			if(prob(OC.fillerprob))
				AST.randomize_ore(minor_ores)
			else
				AST.randomize_ore(OC)
			AST.hardness += OC.hardness_mod
	return 1

//////////////////
///////////////pod_wars asteroids
/turf/simulated/wall/asteroid/pod_wars
	fullbright = 1
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
		var/image/ore_overlay = image('icons/turf/asteroid.dmi',O.name)
		ore_overlay.transform = turn(ore_overlay.transform, pick(0,90,180,-90))
		ore_overlay.pixel_x += rand(-6,6)
		ore_overlay.pixel_y += rand(-6,6)
		src.overlays += ore_overlay

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
	fraction = clamp(fraction, 0.00, 0.99)


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

datum/game_mode/pod_wars/proc/do_team_member_death(var/mob/M, var/datum/pod_wars_team/our_team, var/datum/pod_wars_team/enemy_team)
	our_team.change_points(-1)
	if (M.mind == our_team.commander)
		our_team.change_points(-2)
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
		src.playsound_to_team(team, "sound/effects/ship_alert_major.ogg", 60)

	//Gah, why? Gotta say "The" I guess.
	var/team_name_string = team?.name
	if (team.team_num == TEAM_SYNDICATE)
		team_name_string = "The Syndicate"
	boutput(world, "<h3><span class='alert'>[team_name_string]'s [CS] has been destroyed!!</span></h3>")

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

	src.playsound_to_team(team, "sound/effects/ship_alert_minor.ogg")
	var/team_name_string = team?.name
	if (team.team_num == TEAM_SYNDICATE)
		team_name_string = "The Syndicate"
	boutput(world, "<h3><span class='alert'>[team_name_string]'s [CS] is under attack!!</span></h3>")


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
		logTheThing("debug", null, null, "Something went wrong trying to play a sound for a team=[team]|[pw_team].!!!")
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
	boutput(world, "[active_players] active players/[length(pw_team.members)] total players")
	boutput(world, "")	//L.something

/datum/pod_wars_team
	var/name = "NanoTrasen"
	var/comms_frequency = 0		//used in datum/job/pod_wars/proc/setup_headset (in Jobs.dm) to tune the radio as it's first equipped
	var/area/base_area = null		//base ship area
	var/datum/mind/commander = null
	var/list/members = list()		//list of minds
	var/team_num = 0

	var/points = 100
	var/max_points = 200
	var/list/mcguffins = list()		//Should have 4 AND ONLY 4
	var/commander_job_title			//for commander selection
	var/datum/game_mode/pod_wars/mode

	//These two are for playing sounds, they'll only play for the first death or system destruction.
	var/first_system_destroyed = 0
	var/first_commander_death = 0

	//sound line alt amounts for random selection based on what's in the voice line directory
	var/sl_amt_commander_dies
	var/sl_amt_crit_system_destroyed
	var/sl_amt_lose
	var/sl_amt_losing
	var/sl_amt_win
	var/sl_amt_roundstart
	var/sl_amt_objective_secured
	var/sl_amt_objective_lost_chucks
	var/sl_amt_objective_lost_fortuna
	var/sl_amt_objective_lost_reliant
	var/sl_amt_objective_lost_uvb67

	New(var/datum/game_mode/pod_wars/mode, team_num)
		..()
		src.mode = mode
		src.team_num = team_num
		switch(team_num)
			if (TEAM_NANOTRASEN)
				name = "NanoTrasen"
				commander_job_title = "NanoTrasen Commander"
				base_area = /area/pod_wars/team1 //area north, NT crew
			if (TEAM_SYNDICATE)
				name = "Syndicate"
				commander_job_title = "Syndicate Commander"
				base_area = /area/pod_wars/team2 //area south, Syndicate crew

		setup_voice_line_alt_amounts()
		set_comms(mode)

	proc/change_points(var/amt)
		points += amt
		mode.handle_point_change(src)


	proc/set_comms(var/datum/game_mode/pod_wars/mode)
		comms_frequency = rand(1360,1420)

		while(comms_frequency in mode.frequencies_used)
			comms_frequency = rand(1360,1420)

		mode.frequencies_used += comms_frequency


	proc/accept_initial_players(var/list/players)
		members = players
		if (!select_commander())
			message_admins("[src.name] could not rustle up a Commander. Oh no!")

		for (var/datum/mind/M in players)
			equip_player(M.current, TRUE)
			M.current.antagonist_overlay_refresh(1,0)

	proc/select_commander()

		var/list/high_prio_commanders = get_possible_commanders(1)
		if(length(high_prio_commanders))
			commander = pick(high_prio_commanders)
			return 1

		var/list/med_prio_commanders = get_possible_commanders(2)
		if(length(med_prio_commanders))
			commander = pick(med_prio_commanders)
			return 1

		var/list/low_prio_commanders = get_possible_commanders(3)
		if(length(low_prio_commanders))
			commander = pick(low_prio_commanders)
			return 1

		return 0

	//Really stolen from gang, But this basically just picks everyone who is ready and not hellbanned or jobbanned from Command or Captain
	//priority values 1=favorite,2=medium,3=low job priorities
	proc/get_possible_commanders(var/priority)
		var/list/candidates = list()
		for(var/datum/mind/mind in members)
			var/mob/new_player/M = mind.current
			if (!istype(M)) continue
			if (ishellbanned(M)) continue
			if(jobban_isbanned(M, "Captain")) continue //If you can't captain a Space Station, you probably can't command a starship either...
			if(jobban_isbanned(M, "NanoTrasen Commander")) continue
			if(jobban_isbanned(M, "Syndicate Commander")) continue

			if ((M.ready) && !candidates.Find(M.mind))
				switch(priority)
					if (1)
						if (M.client.preferences.job_favorite == commander_job_title)
							candidates += M.mind
					if (2)
						if (M.client.preferences.jobs_med_priority == commander_job_title)
							candidates += M.mind
					if (3)
						if (M.client.preferences.jobs_low_priority == commander_job_title)
							candidates += M.mind
				candidates += M.mind

		if(!length(candidates))
			return null
		else
			return candidates

	//this initializes the player with all their equipment, edits to their mind, showing antag popup, and initializing player_stats
	//if show_popup is TRUE, then show them the tips popup
	proc/equip_player(var/mob/M, var/show_popup = FALSE)
		var/mob/living/carbon/human/H = M
		var/datum/job/special/pod_wars/JOB

		if (team_num == TEAM_NANOTRASEN)
			if (M.mind == commander)
				JOB = new /datum/job/special/pod_wars/nanotrasen/commander
			else
				JOB = new /datum/job/special/pod_wars/nanotrasen
		else if (team_num == TEAM_SYNDICATE)
			if (M.mind == commander)
				JOB = new /datum/job/special/pod_wars/syndicate/commander
			else
				JOB = new /datum/job/special/pod_wars/syndicate

		//This first bit is for the round start player equipping
		if (istype(M, /mob/new_player))
			var/mob/new_player/N = M
			if (team_num == TEAM_NANOTRASEN)
				if (M.mind == commander)
					H.mind.assigned_role = "NanoTrasen Commander"
				else
					H.mind.assigned_role = "NanoTrasen Pod Pilot"
				H.mind.special_role = "NanoTrasen"

			else if (team_num == TEAM_SYNDICATE)
				if (M.mind == commander)
					H.mind.assigned_role = "Syndicate Commander"
				else
					H.mind.assigned_role = "Syndicate Pod Pilot"
				H.mind.special_role = "Syndicate"
			H = N.create_character(JOB)

		//This second bit is for the in-round player equipping (when cloned)
		else if (istype(H))
			SPAWN_DBG(0)
				H.JobEquipSpawned(H.mind.assigned_role)

		if (!ishuman(H))
			boutput(H, "something went wrong. Horribly wrong. Call 1-800-CODER")
			return

		H.set_clothing_icon_dirty()
		// H.set_loc(pick(pod_pilot_spawns[team_num]))
		boutput(H, "You're in the [name] faction!")
		// bestow_objective(player,/datum/objective/battle_royale/win)
		if (show_popup)
			SHOW_POD_WARS(H)
		if (istype(mode))
			mode.stats_manager?.add_player(H.mind, H.real_name, team_num, (H.mind == commander ? "Commander" : "Pilot"))

	//set the amounts of files for each type of line based on the team and amount of voice line files for that line.
	//files are in sound\voice\pod_wars_voices
	proc/setup_voice_line_alt_amounts()
		switch(team_num)
			if (TEAM_NANOTRASEN)
				sl_amt_commander_dies = 2
				sl_amt_crit_system_destroyed = 2
				sl_amt_lose = 4
				sl_amt_losing = 3
				sl_amt_win = 2
				sl_amt_roundstart = 2
				sl_amt_objective_secured = 3
				sl_amt_objective_lost_chucks = 3
				sl_amt_objective_lost_fortuna = 3
				sl_amt_objective_lost_reliant = 4
				sl_amt_objective_lost_uvb67 = 1
			if (TEAM_SYNDICATE)
				sl_amt_commander_dies = 1
				sl_amt_crit_system_destroyed = 1
				sl_amt_lose = 2
				sl_amt_losing = 0
				sl_amt_win = 2
				sl_amt_roundstart = 1
				sl_amt_objective_secured = 2
				sl_amt_objective_lost_chucks = 2
				sl_amt_objective_lost_fortuna = 2
				sl_amt_objective_lost_reliant = 2
				sl_amt_objective_lost_uvb67 = 2

/obj/pod_base_critical_system
	name = "Critical System"
	icon = 'icons/obj/64x64.dmi'
	icon_state = "critical_system"
	anchored = 1
	density = 1
	bound_width = 64
	bound_height = 64

	var/health = 10000
	var/health_max = 10000
	var/team_num
	var/suppress_damage_message = 0
	var/shielded = 1

	nanotrasen
		team_num = TEAM_NANOTRASEN

	syndicate
		team_num = TEAM_SYNDICATE

	disposing()
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			//get the team datum from its team number right when we allocate points.
			var/datum/game_mode/pod_wars/mode = ticker.mode

			switch(team_num)
				if (TEAM_NANOTRASEN)
					mode.team_NT.mcguffins -= src
				if (TEAM_SYNDICATE)
					mode.team_SY.mcguffins -= src

			mode.announce_critical_system_destruction(team_num, src)
		..()


	ex_act(severity)
		var/damage = 0
		var/damage_mult = 1
		switch(severity)
			if(1)
				damage = rand(30,50)
				damage_mult = 4
			if(2)
				damage = rand(25,40)
				damage_mult = 2
			if(3)
				damage = rand(10,20)
				damage_mult = 1

		src.take_damage(damage*damage_mult)
		return

	bullet_act(var/obj/projectile/P)
		//bullets from friendly turrets don't damage this thingy.
		if (istype(P.proj_data, /datum/projectile/laser/blaster/pod_pilot))
			var/datum/projectile/laser/blaster/pod_pilot/blaster_bolt = P.proj_data
			if (blaster_bolt.turret && blaster_bolt.team_num == src.team_num)
				return

		var/damage = round((P.power*P.proj_data.ks_ratio), 1.0)
		var/damage_mult = 1
		if (damage < 1)
			return

		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				damage_mult = 1
			if(D_PIERCING)
				damage_mult = 1.5
			if(D_ENERGY)
				damage_mult = 1
			if(D_BURNING)
				damage_mult = 0.25
			if(D_SLASHING)
				damage_mult = 0.75

		//for detecting friendly fire. This bit stolen from logging.dm
		var/shooter_data = null
		if (P.mob_shooter)
			shooter_data = P.mob_shooter
		else if (ismob(P.shooter))
			var/mob/M = P.shooter
			shooter_data = M
		var/obj/machinery/vehicle/V
		if (istype(P.shooter,/obj/machinery/vehicle/))
			V = P.shooter
			if (!shooter_data)
				shooter_data = V.pilot

		take_damage(damage*damage_mult, shooter_data)
		return

	attackby(var/obj/item/W, var/mob/user)
		user.lastattacked = src

		//Healing with welding tool
		if (health <= health_max && isweldingtool(W))
			if(!W:try_weld(user, 1))
				return
			take_damage(-30)
			src.visible_message("<span class='alert'>[user] has fixed some of the damage on [src]!</span>")
			if(health >= health_max)
				health = health_max
				src.visible_message("<span class='alert'>[src] is fully repaired!</span>")
			return

		//normal damage stuff
		take_damage(W.force, user)
		src.add_fingerprint(user)

		..()

	get_desc()
		. = "<br><span class='notice'>It looks like it has [health] HP left out of [health_max] HP. You can just tell. What is \"HP\" though? </span>"

	proc/take_damage(var/damage, var/mob/user)
		// if (damage > 0)
		if (shielded)
			return

		src.health -= damage

		//accounting for heals so we don't log the combat as friendly fire.
		if (damage < 0)

			return

		if (!suppress_damage_message && istype(ticker.mode, /datum/game_mode/pod_wars))
			//get the team datum from its team number right when we allocate points.
			var/datum/game_mode/pod_wars/mode = ticker.mode

			mode.announce_critical_system_damage(team_num, src)
			suppress_damage_message = 1
			SPAWN_DBG(2 MINUTES)
				suppress_damage_message = 0


		if (health <= 0)
			qdel(src)

		if (!user)
			return	//don't log if damage isn't done by a user (like it's critters are turrets)

		//Friendly fire check
		if (get_pod_wars_team_num(user) == team_num)
			message_admins("[user] just committed friendly fire against their team's [src]!")
			logTheThing("combat", user, "\[POD WARS\][user] attacks their own team's critical system [src].")

			if (istype(ticker.mode, /datum/game_mode/pod_wars))
				var/datum/game_mode/pod_wars/mode = ticker.mode
				mode.stats_manager?.inc_friendly_fire(user)

//////////////special clone pod///////////////

/obj/machinery/clonepod/pod_wars
	name = "Cloning Pod Deluxe"
	meat_level = 1.#INF
	var/last_check = 0
	var/check_delay = 10 SECONDS
	var/team_num		//used for getting the team datum, this is set to 1 or 2 in the map editor. 1 = NT, 2 = Syndicate
	var/datum/pod_wars_team/team
	// is_speedy = 1	//setting this var does nothing atm, its effect is done and it is set by being hit with the object
	perfect_clone = 1

	process()
		meat_level = initial(meat_level)	//infinite meat...

		if(!src.attempting)
			if (world.time - last_check >= check_delay)
				if (!team && istype(ticker.mode, /datum/game_mode/pod_wars))
					var/datum/game_mode/pod_wars/mode = ticker.mode
					if (team_num == TEAM_NANOTRASEN)
						team = mode.team_NT
					else if (team_num == TEAM_SYNDICATE)
						team = mode.team_SY
				last_check = world.time
				INVOKE_ASYNC(src, /obj/machinery/clonepod/pod_wars.proc/growclone_a_ghost)
		return..()

	New()
		..()
		animate_rainbow_glow(src) // rgb shit cause it looks cool
		SubscribeToProcess()
		last_check = world.time

	ex_act(severity)
		return

	disposing()
		..()
		UnsubscribeProcess()

	//make cloning faster, by a lot. lol, I gues speed modules don't do anything when I override this...
	healing_multiplier()
		return 15

	proc/growclone_a_ghost()
		var/list/to_search
		if (istype(team))
			to_search = team.members
		else
			return

		for(var/datum/mind/mind in to_search)
			if((istype(mind.current, /mob/dead/observer) || isdead(mind.current)) && mind.current.client && !mind.dnr)
				//prune puritan trait
				mind.current?.traitHolder.removeTrait("puritan")
				var/success = growclone(mind.current, mind.current.real_name, mind, mind.current?.bioHolder, traits=mind.current?.traitHolder.traits.Copy())
				if (success && team)
					SPAWN_DBG(1)
						team.equip_player(src.occupant, FALSE)
				break

////////////////////////////////////////////////

/obj/forcefield/energyshield/perma/pod_wars
	name = "Permanent Military-Grade Forcefield"
	desc = "A permanent force field that prevents non-authorized entities from passing through it."
	var/team_num = 0		//1 = NT, 2 = SY

	CanPass(atom/A, turf/T)
		if (ismob(A))
			var/mob/M = A
			if (team_num == get_pod_wars_team_num(M))
				return 1
		return 0

/obj/forcefield/energyshield/perma/pod_wars/nanotrasen
	team_num = 1
	color = "#6666FF"
/obj/forcefield/energyshield/perma/pod_wars/syndicate
	team_num = 2
	color = "#FF6666"

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


/obj/item/turret_deployer/pod_wars
	name = "Turret Deployer"
	desc = "A turret deployment thingy. Use it in your hand to deploy."
	icon_state = "st_deployer"
	w_class = 4
	health = 125
	quick_deploy_fuel = 2
	var/turret_path = /obj/deployable_turret/pod_wars

	//this is a band aid cause this is broke, delete this override when merged properly and fixed.
	// attackby(obj/item/W, mob/user)
	// 	user.lastattacked = src
	// 	..()

	spawn_turret(var/direct)
		var/obj/deployable_turret/pod_wars/turret = new turret_path(src.loc,direction=direct)
		turret.health = src.health
		turret.reconstruction_time = 0		//can't reconstruct itself
		//turret.emagged = src.emagged
		turret.damage_words = src.damage_words
		turret.quick_deploy_fuel = src.quick_deploy_fuel
		return turret

/obj/deployable_turret/pod_wars
	name = "Ship Defense Turret"
	desc = "A ship defense turret."
	health = 100
	max_health = 100
	wait_time = 20 //wait if it can't find a target
	range = 8 // tiles
	burst_size = 3 // number of shots to fire. Keep in mind the bullet's shot_count
	fire_rate = 3 // rate of fire in shots per second
	angle_arc_size = 180
	quick_deploy_fuel = 2
	var/deployer_path = /obj/deployable_turret/pod_wars
	var/destroyed = 0
	var/reconstruction_time = 5 MINUTES

	//Might be nice to allow players to "repair"  Dead turrets to speed up their timer, but not now. too lazy - kyle

	New(var/direction)
		..(direction=direction)

	//just "deactivates"
	die()
		playsound(get_turf(src), "sound/impact_sounds/Machinery_Break_1.ogg", 50, 1)
		if (!destroyed)
			destroyed = 1
			new /obj/decal/cleanable/robot_debris(src.loc)
			src.alpha = 30
			src.opacity = 0
			if (reconstruction_time)
				sleep(reconstruction_time)
				src.opacity = 1
				src.alpha = 255
				health = initial(health)
				destroyed = 0
				active = 1
			else
				..()

	spawn_deployer()
		var/obj/item/turret_deployer/deployer = new deployer_path(src.loc)
		deployer.health = src.health
		//deployer.emagged = src.emagged
		deployer.damage_words = src.damage_words
		deployer.quick_deploy_fuel = src.quick_deploy_fuel
		return deployer

	seek_target()
		src.target_list = list()
		for (var/mob/living/C in mobs)
			if(!src)
				break

			if (!isnull(C) && src.target_valid(C))
				src.target_list += C
				var/distance = get_dist(C.loc,src.loc)
				src.target_list[C] = distance

			else
				continue

		//VERY POSSIBLY UNNEEDED, -KYLE
		// for (var/obj/machinery/vehicle/V in by_cat[TR_CAT_PODS_AND_CRUISERS])
		// 	if (pod_target_valid(V))
		// 		var/distance = get_dist(V.loc,src.loc)
		// 		target_list[V] = distance

		if (src.target_list.len>0)
			var/min_dist = 99999

			for (var/atom/T in src.target_list)
				if (src.target_list[T] < min_dist)
					src.target = T
					min_dist = src.target_list[T]

			src.icon_state = "[src.icon_tag]_active"

			playsound(src.loc, "sound/vox/woofsound.ogg", 40, 1)

		return src.target

	//VERY POSSIBLY UNNEEDED, -KYLE
	// proc/pod_target_valid(var/obj/machinery/vehicle/V )
	// 	var/distance = get_dist(V.loc,src.loc)
	// 	if(distance > src.range)
	// 		return 0

	// 	if (ismob(V.pilot))
	// 		return is_friend(V.pilot)
	// 	else
	// 		return 0

/obj/item/turret_deployer/pod_wars/nt
	icon_tag = "nt"
	turret_path = /obj/deployable_turret/pod_wars/nt

/obj/deployable_turret/pod_wars/nt
	deployer_path = /obj/deployable_turret/pod_wars/nt
	projectile_type = /datum/projectile/laser/blaster/pod_pilot/blue_NT/turret
	current_projectile = new/datum/projectile/laser/blaster/pod_pilot/blue_NT/turret
	icon_tag = "nt"

	is_friend(var/mob/living/C)
		if (!C.ckey || !C.mind)
			return 1
		if (C.mind?.special_role == "NanoTrasen")
			return 1
		else
			return 0

/obj/deployable_turret/pod_wars/nt/activated
	anchored=1
	active=1
	north
		dir=NORTH
	south
		dir=SOUTH
	east
		dir=EAST
	west
		dir=WEST


/obj/item/turret_deployer/pod_wars/sy
	icon_tag = "st"
	turret_path = /obj/deployable_turret/pod_wars/sy

/obj/deployable_turret/pod_wars/sy
	deployer_path = /obj/deployable_turret/pod_wars/sy
	projectile_type = /datum/projectile/laser/blaster/pod_pilot/red_SY/turret
	current_projectile = new/datum/projectile/laser/blaster/pod_pilot/red_SY/turret
	icon_tag = "st"

	is_friend(var/mob/living/C)
		if (!C.ckey || !C.mind)
			return 1
		if (C.mind.special_role == "Syndicate")
			return 1
		else
			return 0

/obj/deployable_turret/pod_wars/sy/activated
	anchored=1
	active=1
	north
		dir=NORTH
	south
		dir=SOUTH
	east
		dir=EAST
	west
		dir=WEST

/obj/item/shipcomponent/secondary_system/lock/pw_id
	name = "ID Card Hatch Locking Unit"
	desc = "A basic hatch locking mechanism with a ID card scanner."
	system = "Lock"
	f_active = 1
	power_used = 0
	icon_state = "lock"
	code = ""
	configure_mode = 0 //If true, entering a valid code sets that as the code.
	var/team_num = 0
	var/obj/item/card/id/assigned_id = null

	// Use(mob/user as mob)



	show_lock_panel(mob/living/user)
		if (isliving(user))
			var/obj/item/card/id/I = user.get_id()

			if (isnull(assigned_id))
				if (istype(I))
					boutput(usr, "<span class='notice'>[ship]'s locking mechinism recognizes [I] as its key!</span>")
					playsound(src.loc, "sound/machines/ping.ogg", 50, 0)
					assigned_id = I
					team_num = get_team(I)
					ship.locked = 0
					return

			if (istype(I))
				if (I == assigned_id || get_team(I) == team_num)
					ship.locked = !ship.locked
					boutput(usr, "<span class='alert'>[ship] is now [ship.locked ? "locked" : "unlocked"]!</span>")



	proc/get_team(var/obj/item/card/id/I)
		switch(I.assignment)
			if("NanoTrasen Commander")
				return TEAM_NANOTRASEN
			if("NanoTrasen Pilot")
				return TEAM_NANOTRASEN
			if("Syndicate Commander")
				return TEAM_SYNDICATE
			if("Syndicate Pilot")
				return TEAM_SYNDICATE
		return -1

//emergency Fabs

ABSTRACT_TYPE(/obj/machinery/macrofab/pod_wars)
/obj/machinery/macrofab/pod_wars
	name = "Emergency Combat Pod Fabricator"
	desc = "A sophisticated machine that fabricates short-range emergency pods from a nearby reserve of supplies."
	createdObject = /obj/machinery/vehicle/arrival_pod
	itemName = "emergency pod"
	sound_volume = 15
	var/team_num = 0


	attack_hand(var/mob/user as mob)
		if (get_pod_wars_team_num(user) != team_num)
			boutput(user, "<span class='alert'>This machine's design makes no sense to you, you can't figure out how to use it!</span>")
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
	anchored = 0
	var/weapon_type = /obj/item/shipcomponent/mainweapon/phaser/short
	speed = 1.7

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

		mining
			name = "NT Mining Dingy"
			weapon_type = /obj/item/shipcomponent/mainweapon/bad_mining

			New()
				..()
				equip_mining()

	syndicate
		name = "Syndicate Combat Dingy"
		icon_state = "syndiputt"

		mining
			name = "Syndicate Mining Dingy"
			weapon_type = /obj/item/shipcomponent/mainweapon/bad_mining

			New()
				equip_mining()
				..()

//////////survival_machete//////////////
/obj/item/survival_machete
	name = "pilot survival machete"
	desc = "This peculularly shaped design was used by the Soviets nearly a century ago. It's also useful in space."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "surv_machete_nt"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "surv_machete"
	force = 10.0
	throwforce = 15.0
	throw_range = 5
	hit_type = DAMAGE_STAB
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	burn_type = 1
	stamina_damage = 25
	stamina_cost = 10
	stamina_crit_chance = 40
	pickup_sfx = "sound/items/blade_pull.ogg"
	hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)
	syndicate
		icon_state = "surv_machete_st"

////////////////////PDAs and PDA Accessories/////////////////////
/obj/item/device/pda2/pod_wars
	setup_default_cartridge = /obj/item/disk/data/cartridge/pod_pilot //hos cart gives access to manifest compared to regular sec cart, useful for NTSO
	mailgroups = list()
	bombproof = 1

	nanotrasen
		icon_state = "pda-nt"
		setup_default_module = /obj/item/device/pda_module/flashlight/nt_blue
	
	syndicate
		icon_state = "pda-syn"
		setup_default_module = /obj/item/device/pda_module/flashlight/sy_red

/obj/item/device/pda_module/flashlight/nt_blue
	name = "NanoTrasen Blue Flashlight Module"
	desc = "Love (or work for) NanoTrasen? This'll be your favorite flashlight!"
	lumlevel = 0.8
	light_r = 61
	light_g = 156
	light_b = 255


/obj/item/device/pda_module/flashlight/sy_red
	name = "Syndicate Red Flashlight Module"
	desc = "Hate (or used to work for) NanoTrasen? This'll be your favorite flashlight!"
	lumlevel = 0.8
	//#ff4043
	light_r = 255
	light_g = 64
	light_b = 67

/obj/item/disk/data/cartridge/pod_pilot
	name = "\improper Standard Utility cartridge"
	desc = "A must for any one who braves the vast emptiness of space."
	icon_state = "cart-network"

	New()
		..()
		src.root.add_file( new /datum/computer/file/pda_program/fileshare(src))
		src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
		src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
		src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))


////////////////Champagne/////////////////////////////
/obj/table/wood/round/champagne
	name = "champagne table"
	desc = "It makes champagne. Who ever said spontanious generation was false?"
	var/to_spawn = /obj/item/reagent_containers/food/drinks/bottle/champagne/breakaway_glass
	var/turf/T 		//the turf this obj spawns at.

	New()
		..()
		T = get_turf(src)
		while (T)
			if (!locate(to_spawn) in T.contents)
				var/obj/item/champers = new /obj/item/reagent_containers/food/drinks/bottle/champagne/breakaway_glass(T)
				champers.pixel_y = 10
				champers.pixel_x = 1
			sleep(8 SECONDS)

	disposing()
		T = null
		..()




/obj/machinery/manufacturer/pod_wars
	name = "Ship Component Fabricator"
	desc = "A manufacturing unit calibrated to produce parts for ships."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resource_amt = 20
	var/team_num = 0			//NT = 1, SY = 2

	free_resources = list(
		/obj/item/material_piece/mauxite,
		/obj/item/material_piece/pharosium,
		/obj/item/material_piece/molitz
	)
	available = list(
		/datum/manufacture/pod_wars/barricade,
		/datum/manufacture/pod_wars/energy_concussion_grenade,
		/datum/manufacture/pod_wars/energy_frag_grenade,
		/datum/manufacture/pod_wars/lock,
		/datum/manufacture/putt/engine,
		/datum/manufacture/putt/boards,
		/datum/manufacture/putt/control,
		/datum/manufacture/putt/parts,
		/datum/manufacture/pod/boards,
		/datum/manufacture/pod/control,
		/datum/manufacture/pod/parts,
		/datum/manufacture/pod/engine,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/cargohold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/pod/weapon/mining,
		/datum/manufacture/pod/weapon/mining_weak,
		/datum/manufacture/pod/weapon/taser,
		/datum/manufacture/pod/weapon/laser/short,
		/datum/manufacture/pod/weapon/laser,
		/datum/manufacture/pod/weapon/disruptor,
		/datum/manufacture/pod/weapon/disruptor/light,
		/datum/manufacture/pod/weapon/shotgun,
		/datum/manufacture/pod/weapon/ass_laser,
		/datum/manufacture/pod_wars/cell_high,
		/datum/manufacture/pod_wars/cell_higher,
		/datum/manufacture/pod_wars/cell_pod_wars_basic,
		/datum/manufacture/pod_wars/cell_pod_wars_standard,
		/datum/manufacture/pod_wars/cell_pod_wars_high
	)

	New()
		add_team_armor()
		..()

	proc/add_team_armor()
		return

	attack_hand(var/mob/user as mob)
		if (get_pod_wars_team_num(user) != src.team_num)
			boutput(user, "<span class='alert'>This machine's design makes no sense to you, you can't figure out how to use it!</span>")
			return

		..()

/obj/machinery/manufacturer/pod_wars/nanotrasen
	name = "NanoTrasen Ship Component Fabricator"
	team_num = TEAM_NANOTRASEN
	add_team_armor()
		available += list(
		/datum/manufacture/pod_wars/pod/armor_light/nt,
		/datum/manufacture/pod_wars/pod/armor_robust/nt
		)
/obj/machinery/manufacturer/pod_wars/syndicate
	name = "Syndicate Ship Component Fabricator"
	team_num = TEAM_SYNDICATE
	add_team_armor()
		available += list(
		/datum/manufacture/pod_wars/pod/armor_light/sy,
		/datum/manufacture/pod_wars/pod/armor_robust/sy
		)

////////////////pod-weapons//////////////////
/datum/manufacture/pod/weapon/mining_weak
	name = "Mining Phaser System"
	item_paths = list("MET-1","CON-1")
	item_amounts = list(10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/bad_mining)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/mining
	name = "Plasma Cutter System"
	item_paths = list("MET-2","CON-2", "telecrystal")
	item_amounts = list(50,50,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/mining)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/taser
	name = "Mk.1 Combat Taser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(20,20,30)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/taser)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/laser
	name = "Mk.2 Scout Laser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(25,40,30)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/laser/short
	name = "Mk.2 CQ Laser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(20,20,20)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser/short)
	time = 10 SECONDS

/datum/manufacture/pod/weapon/disruptor
	name = "Heavy Disruptor Array"
	item_paths = list("MET-3","CON-2","CRY-1", "telecrystal")
	item_amounts = list(20,20,50, 20)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/disruptor)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/disruptor/light
	name = "Mk.3 Disruptor"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(20,30,30)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/disruptor_light)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/ass_laser
	name = "Mk.4 Assault Laser"
	item_paths = list("MET-3","CON-2","CRY-1", "telecrystal")
	item_amounts = list(35,30,30, 30)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser_ass)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/shotgun
	name = "SPE-12 Ballistic System"
	item_paths = list("MET-3","CON-2","CRY-1")
	item_amounts = list(50,40,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/gun)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

////////////pod-armor///////////////////////
/datum/manufacture/pod_wars/pod/armor_light
	name = "Light NT Pod Armor"
	item_paths = list("MET-3","CON-1")
	item_amounts = list(50,50)
	item_outputs = list(/obj/item/pod/armor_light)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod_wars/pod/armor_light/nt
	name = "Light NT Pod Armor"
	item_outputs = list(/obj/item/pod/nt_light)

/datum/manufacture/pod_wars/pod/armor_light/sy
	name = "Light Syndicate Pod Armor"
	item_outputs = list(/obj/item/pod/sy_light)

/datum/manufacture/pod_wars/pod/armor_robust
	name = "Heavy Pod Armor"
	item_paths = list("MET-3","CON-2", "DEN-3")
	item_amounts = list(50,30, 10)
	item_outputs = list(/obj/item/pod/armor_heavy)
	time = 30 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod_wars/pod/armor_robust/nt
	name = "Robust NT Pod Armor"
	item_outputs = list(/obj/item/pod/nt_robust)

/datum/manufacture/pod_wars/pod/armor_robust/sy
	name = "Robust Syndicate Pod Armor"
	item_outputs = list(/obj/item/pod/sy_robust)

//costs a good bit more than the standard jetpack. for balance reasons here. to make jetpacks a commodity.
/datum/manufacture/pod_wars/jetpack
	name = "Jetpack"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(30,50)
	item_outputs = list(/obj/item/tank/jetpack)
	time = 60 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pod_wars/industrialboots
	name = "Mechanised Boots"
	item_paths = list("MET-3","CON-2","POW-2", "DEN-2")
	item_amounts = list(50,50,70,50)
	item_outputs = list(/obj/item/clothing/shoes/industrial)
	time = 120 SECONDS
	create = 1
	category = "Clothing"


/obj/machinery/manufacturer/mining/pod_wars
	New()
		available -= /datum/manufacture/jetpack
		available += /datum/manufacture/pod_wars/jetpack

		available -= /datum/manufacture/industrialboots
		available += /datum/manufacture/pod_wars/industrialboots

		hidden = list()
		..()

/obj/machinery/manufacturer/medical/pod_wars
	New()
		available += /datum/manufacture/medical_backpack
		..()


/datum/manufacture/pod_wars/cell_high
	name = "Standard Large Weapon Cell"
	item_paths = list("MET-2", "CON-2", "POW-1")
	item_amounts = list(5, 20, 30)
	item_outputs = list(/obj/item/ammo/power_cell/high_power)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

/datum/manufacture/pod_wars/cell_higher
	name = "Standard Bubs Weapon Cell"
	item_paths = list("MET-3", "CON-2", "POW-1", "telecrystal")
	item_amounts = list(5, 20, 60, 20)
	item_outputs = list(/obj/item/ammo/power_cell/higher_power)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

////////////////////////////

/datum/manufacture/pod_wars/cell_pod_wars_basic
	name = "Basic Self-Charging Weapon Cell"
	item_paths = list("MET-2", "DEN-1", "CON-2", "POW-1")
	item_amounts = list(10, 20, 30, 30)
	item_outputs = list(/obj/item/ammo/power_cell/self_charging/pod_wars_basic)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

/datum/manufacture/pod_wars/cell_pod_wars_standard
	name = "Standard Self-Charging Weapon Cell"
	item_paths = list("DEN-2", "CON-2", "POW-1", "telecrystal")
	item_amounts = list(30, 60, 50, 10)
	item_outputs = list(/obj/item/ammo/power_cell/self_charging/pod_wars_standard)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

/datum/manufacture/pod_wars/cell_pod_wars_high
	name = "Robust Self-Charging Weapon Cell"
	item_paths = list("DEN-2", "CON-2", "POW-2", "telecrystal")
	item_amounts = list(30, 70, 30, 30)
	item_outputs = list(/obj/item/ammo/power_cell/self_charging/pod_wars_high)
	time = 1 SECONDS
	create = 1
	category = "Ammo"



//It's cheap, use it!
/datum/manufacture/pod_wars/lock
	name = "Pod Lock (ID Card)"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/lock/pw_id)
	time = 1 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/pod_wars/barricade
	name = "Deployable Barricade"
	item_paths = list("MET-2")
	item_amounts = list(5)
	item_outputs = list(/obj/item/deployer/barricade)
	time = 1 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/pod_wars/energy_concussion_grenade

	name = "Concussion Grenade"
	item_paths = list("MET-1", "CON-1", "telecrystal")
	item_amounts = list(5, 5, 5)
	item_outputs = list(/obj/item/old_grenade/energy_concussion)
	time = 1 SECONDS
	create = 1
	category = "Weapon"

/datum/manufacture/pod_wars/energy_frag_grenade

	name = "Blast Grenade"
	item_paths = list("MET-2", "CON-2", "telecrystal")
	item_amounts = list(5, 5, 5)
	item_outputs = list(/obj/item/old_grenade/energy_frag)
	time = 1 SECONDS
	create = 1
	category = "Weapon"

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
				src.updateIcon()
				boutput(usr, "<span class='notice'>Please press a number to bind this ability to...</span>")
				return

		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span class='alert'>You can't use this spell here.</span>")
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
			SPAWN_DBG(0)
				spell.handleCast()
		return


/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/datum/abilityHolder/pod_pilot
	usesPoints = 0
	regenRate = 0
	tabName = "pod_pilot"
	// notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
	points = 0
	pointName = "points"

	New()
		..()
		add_all_abilities()


	disposing()
		..()

	onLife(var/mult = 1)
		if(..()) return

	proc/add_all_abilities()
		src.addAbility(/datum/targetable/pod_pilot/scoreboard)

//can't remember why I did this as an ability. Probably better to add directly like I did in kudzumen, but later... -kyle
//Wait, maybe I never used this. I can't remember, it's too late now to think and I'll just keep it in case I secretly had a good reason to do this.
/datum/targetable/pod_pilot
	icon = 'icons/mob/pod_pilot_abilities.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/pod_pilot
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0
	var/unlock_message = null
	var/can_cast_anytime = 0		//while alive

	New()
		var/atom/movable/screen/ability/topBar/pod_pilot/B = new /atom/movable/screen/ability/topBar/pod_pilot(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	onAttach(var/datum/abilityHolder/H)
		..()
		if (src.unlock_message && src.holder && src.holder.owner)
			boutput(src.holder.owner, __blue("<h3>[src.unlock_message]</h3>"))
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/pod_pilot()
			object.icon = src.icon
			object.owner = src
		if (src.last_cast > world.time)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state
		return

	castcheck()
		if (!holder)
			return 0
		var/mob/living/M = holder.owner
		if (!M)
			return 0
		if (!(iscarbon(M) || ismobcritter(M)))
			boutput(M, __red("You cannot use any powers in your current form."))
			return 0
		if (can_cast_anytime && !isdead(M))
			return 1
		if (!can_act(M, 0))
			boutput(M, __red("You can't use this ability while incapacitated!"))
			return 0

		if (src.not_when_handcuffed && M.restrained())
			boutput(M, __red("You can't use this ability when restrained!"))
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/datum/targetable/pod_pilot/scoreboard
	name = "scoreboard"
	desc = "How many scores do we have?"
	icon = 'icons/mob/pod_pilot_abilities.dmi'
	icon_state = "empty"
	targeted = 0
	cooldown = 0
	special_screen_loc = "NORTH,CENTER-2"

	onAttach(var/datum/abilityHolder/H)
		object.mouse_opacity = 0
		// object.maptext_y = -32
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			object.vis_contents += mode.board
		return


///////////Headsets////////////////
//OK look, I made these objects, but I probably didn't need to. Setting the frequencies is done in the job equip.
//Mainly I did it to give them the icon_override vars. Don't spawn these unless you want to set their secure frequencies yourself, because that's what you'd have to do. -Kyle
/obj/item/device/radio/headset/pod_wars
	protected_radio = 1
	var/team = 0

	//You can only pick this up if you're on the correct team, otherwise it explodes.
	//exactly the same as /obj/item/card/id/pod_wars. Copy paste bad, but these two things I don't want people stealing, would be real lame... Might get rid of in the future if this structure isn't required.
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team)
			..()
		else
			boutput(user, "<span class='alert'>The headset <b>explodes</b> as you reach out to grab it!</span>")
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)

/obj/item/device/radio/headset/pod_wars/nanotrasen
	name = "Radio Headset"
	desc = "A radio headset that is also capable of communicating over... wait, isn't that frequency illegal?"
	icon_state = "headset"
	secure_frequencies = list("g" = R_FREQ_SYNDICATE)
	secure_classes = list(RADIOCL_COMMAND)
	icon_override = "nt"
	team = TEAM_NANOTRASEN

	commander
		icon_override = "cap"	//get better thingy

/obj/item/device/radio/headset/pod_wars/syndicate
	name = "Radio Headset"
	desc = "A radio headset that is also capable of communicating over... wait, isn't that frequency illegal?"
	icon_state = "headset"
	secure_frequencies = list("g" = R_FREQ_SYNDICATE)
	secure_classes = list(RADIOCL_SYNDICATE)
	protected_radio = 1
	icon_override = "syndie"
	team = TEAM_SYNDICATE

	commander
		icon_override = "syndieboss"


/////////shit//////////////

/obj/control_point_computer
	name = "computer"	//name it based on area.
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	density = 1
	anchored = 1.0
	var/datum/light/light
	var/light_r =1
	var/light_g = 1
	var/light_b = 1

	var/owner_team = 0			//Which team currently controls this computer/area? 0 = neutral, 1 = NT, 2 = SY
	var/capturing_team = 0		//Which team is capturing this computer/area? 0 = neutral, 1 = NT, 2 = SY 			//UNUSED
	var/datum/control_point/ctrl_pt
	var/can_be_captured = 0		//can't capture this point until it's set to TRUE. Will be done by control points at 15 MIN atm.

	New()
		..()
		light = new/datum/light/point
		light.set_brightness(0.8)
		light.set_color(light_r, light_g, light_b)
		light.attach(src)

		//name it based on area.

	ex_act()
		return

	meteorhit(var/obj/O as obj)
		return

	//called from the action bar completion in src.attack_hand()
	proc/capture(var/mob/user)
		var/team_num = get_pod_wars_team_num(user)
		owner_team = team_num
		update_light_color()

		ctrl_pt.capture(user, team_num)

	attack_hand(mob/user as mob)
		if (!can_be_captured)
			var/cur_time
			var/datum/game_mode/pod_wars/mode = ticker.mode
			if (istype(mode))
				cur_time = round((mode.activate_control_points_time-ticker.round_elapsed_ticks) / (1 MINUTES), 1)	//converts to minutes
			else
				cur_time = round( 15 MINUTES / 1 MINUTES, 1)


			boutput(user, "<span class='notice'>This computer seems to be frozen on a space-weather tracking screen. It looks like a large ion storm will be passing this system in about <b class='alert'>[(cur_time)] minutes mission time</b>.<br>You can't input any commands to run the control protocols for this satelite...</span>")
			playsound(src, "sound/machines/buzz-sigh.ogg", 30, 1, flags = SOUND_IGNORE_SPACE)
			return 0
		if (owner_team != get_pod_wars_team_num(user))
			var/duration = is_commander(user) ? 10 SECONDS : 20 SECONDS
			playsound(get_turf(src), "sound/machines/warning-buzzer.ogg", 150, 1, flags = SOUND_IGNORE_SPACE)	//loud

			SETUP_GENERIC_ACTIONBAR(user, src, duration, /obj/control_point_computer/proc/capture, list(user),\
			 null, null, "[user] successfully enters [his_or_her(user)] command code into \the [src]!")
		else
			boutput(user, "You can't think of anything else to do on this console...")

	proc/is_commander(var/mob/user)
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			if (user.mind == mode.team_NT.commander)
				return 1
			else if (user.mind == mode.team_SY.commander)
				return 1
		return 0


	// //changes vars to sync up with the manager datum
	// proc/update_from_manager(var/owner_team, var/capturing_team)
	// 	src.owner_team = owner_team
	// 	src.capturing_team = capturing_team

	// proc/prevent_capture(var/mob/user, var/user_team)
	// 	if (owner_team != user_team && capturing_team != user_team)
	// 		capture_start(user, user_team)
	// 	return

	// proc/start_capture(var/mob/user, var/user_team)

	// 	capture_start(user, user_team)

	//change colour and owner team when captured.
	//this doesn't work right now. idc -kyle
	proc/update_light_color()
		//blue for NT|1, red for SY|2, white for neutral|0.
		if (owner_team == TEAM_NANOTRASEN)
			light_r = 0
			light_g = 0
			light_b = 1
			icon_state = "computer_blue"
		else if (owner_team == TEAM_SYNDICATE)
			light_r = 1
			light_g = 0
			light_b = 0
			icon_state = "computer_red"
		else
			light_r = 1
			light_g = 1
			light_b = 1
			icon_state = "computer_generic"

		light.set_color(light_r, light_g, light_b)

/obj/warp_beacon/pod_wars
	var/control_point 		//currently only use values FORTUNA, RELIANT, UVB67 		//set in map file
	var/current_owner		//which team is the owner right now. Acceptable values: null, TEAM_NANOTRASEN = 1, TEAM_SYNDICATE = 1

	ex_act()
		return
	meteorhit(var/obj/O as obj)
		return
	attackby(obj/item/W as obj, mob/user as mob)
		return

	//These are basically the same as "normal" pod_wars beacons, but they won't have a capture point so they should never get an owner team
	//so nobody will be able to warp to them, they can only navigate towards them with pod sensors.
	spacejunk
		name = "spacejunk warp_beacon"
		invisibility = 101
		alpha = 100			//just to be clear


/datum/control_point
	var/name = "Capture Point"

	var/list/beacons = list()
	var/obj/control_point_computer/computer
	var/area/capture_area
	var/capture_value = 0				//values from -100 to 100. Positives denote NT, negatives denote SY.  	/////////UNUSED
	var/capture_rate = 1				//1 or 3 based on if a commander has entered their code.  				/////////UNUSED
	var/capturing_team					//0 if not moving, either uncaptured or at max capture. 1=NT, 2=SY  	/////////UNUSED
	var/owner_team = 0						//1=NT, 2=SY, not the team datum
	var/true_name						//backend name, var/name is the user readable name. Used for warp beacon searching, etc.
	var/last_cap_time					//Time it was last captured.
	var/crate_rewards_tier = 0			//var 0-3 none/low/med/high. Should correlate to holding the point for <5 min, <10 min, <15
	var/datum/game_mode/pod_wars/mode

	New(var/obj/control_point_computer/computer, var/area/capture_area, var/name, var/true_name, var/datum/game_mode/pod_wars/mode)
		..()
		src.computer = computer
		src.capture_area = capture_area
		src.name = name
		src.true_name = true_name
		src.mode = mode

		for(var/obj/warp_beacon/pod_wars/B in warp_beacons)
			if (B.control_point == true_name)
				src.beacons += B

	//deliver crate for appropriate tier.in front of this control point for the owner of the point
	proc/do_item_delivery()
		if (!src.computer)
			message_admins("SOMETHING WENT THE CONTROL POINTS!!!owner_team=[owner_team]|1 is NT, 2 is SY")
			logTheThing("debug", null, null, "PW CONTROL POINT has null computer var.!!!owner_team=[owner_team]")
			return 0
		if (src.owner_team == 0)
			return 0

		var/turf/T = get_step(src.computer, src.computer.dir)		//tile in front of computer
		var/spawned_crate = FALSE

		//GAZE UPON MY WORKS AND DESPAIR!!!
		//Spawns a crate at the correct time at the correct tier.
		if (TIME > last_cap_time + 5 MINUTES && src.crate_rewards_tier == 0)	//Do anything special on capture here? idk, not yet at least...
			src.crate_rewards_tier ++
			return 0
		else if (TIME > last_cap_time + 10 MINUTES && src.crate_rewards_tier == 1)
			new/obj/storage/secure/crate/pod_wars_rewards(loc = T, team_num = src.owner_team, tier = src.crate_rewards_tier)
			src.crate_rewards_tier ++
			spawned_crate = TRUE

		else if (TIME > last_cap_time + 15 MINUTES && src.crate_rewards_tier == 2)
			new/obj/storage/secure/crate/pod_wars_rewards(loc = T, team_num = src.owner_team, tier = src.crate_rewards_tier)
			src.crate_rewards_tier ++
			spawned_crate = TRUE

		//ok, this is shit. To explain, if the tier is 3, then it'll be 15 minutes, if it's 4, it'll be 20 minutes, if it's 5, it'll be 25 minutes, etc...
		else if (TIME >= last_cap_time + (15 MINUTES + 5 MINUTES * (src.crate_rewards_tier-3) ) && src.crate_rewards_tier == 3)
			new/obj/storage/secure/crate/pod_wars_rewards(loc = T, team_num = src.owner_team, tier = src.crate_rewards_tier)
			src.crate_rewards_tier ++
			spawned_crate = TRUE

		//subtract 2 points from the enemy team every time a rewards crate is spawned on a point.
		if (spawned_crate == TRUE && istype(ticker.mode, /datum/game_mode/pod_wars))
			//get the team datum from its team number right when we allocate points.
			var/datum/game_mode/pod_wars/mode = ticker.mode

			//get the opposite team. lower their points
			var/datum/pod_wars_team/other_team
			switch(src.owner_team)
				if (TEAM_NANOTRASEN)
					other_team = mode.team_SY
				if (TEAM_SYNDICATE)
					other_team = mode.team_NT
			//error checking
			if (!other_team)
				message_admins("Can't grab the opposite team for control point [src.name]. It's owner_team value is:[src.owner_team]")
				logTheThing("debug", null, null, "Can't grab the opposite team for control point [src.name]. It's owner_team value is:[src.owner_team]")
				return 0
			other_team.change_points(-5)

		return 1



	proc/capture(var/mob/user, var/team_num)
		src.owner_team = team_num
		src.last_cap_time = TIME
		//rewards tier goes to back down to 1 AFTER giving the enemy a crate. A little sort of catchup mechanic...
		if (src.crate_rewards_tier > 0)
			src.do_item_delivery()
			src.crate_rewards_tier = 1

		//update beacon teams
		for (var/obj/warp_beacon/pod_wars/B in beacons)
			B.current_owner = team_num

		var/datum/pod_wars_team/pw_team
		//This needs to give the actual team up to the control point datum, which in turn gives it to the game_mode datum to handle it
		//I don't think I do anything special with the team there yet, but I might want it for something eventually. Most things are just fine with the team_num.
		switch(team_num)
			if (TEAM_NANOTRASEN)
				pw_team = mode.team_NT
			if (TEAM_SYNDICATE)
				pw_team = mode.team_SY

		//update scoreboard
		mode.handle_control_point_change(src, user, pw_team)

		//log player_stats. Increment nearby player's capture point stat
		if (mode.stats_manager)
			mode.stats_manager.inc_control_point_caps(team_num, src.computer)


//I'll probably remove this all cause it's so shit, but in case I want to come back and finish it, I leave - kyle
	// proc/receive_prevent_capture(var/mob/user, var/user_team)
	// 	capturing_team = 0
	// 	return

	// proc/capture_start(var/mob/user, var/user_team)
	// 	if (owner_team == user_team)
	// 		boutput_
	// 	if (capturing_team == user_team)
	// 		capture_rate = 1
	// 		//is a commander, then change capture rate to be higher
	// 		if (istype(ticker.mode, /datum/game_mode/pod_wars))
	// 			var/datum/game_mode/pod_wars/mode = ticker.mode
	// 			if (user.mind == mode.team_NT.commander)
	// 				capture_rate = 3
	// 			else if (user.mind == mode.team_SY.commander)
	// 				capture_rate = 3


	// proc/process()

	// 	//clamp values, set capturing team to 0
	// 	if (capture_value >= 100)
	// 		capture_value = 100
	// 		capturing_team = 0
	// 		computer.update_from_manager(TEAM_NANOTRASEN, capturing_team)

	// 	else if (capture_value <= -100)
	// 		capture_value = -100
	// 		capturing_team = 0
	// 		computer.update_from_manager(TEAM_SYNDICATE, capturing_team)

	// 	if (capturing_team == TEAM_NANOTRASEN)
	// 		capture_value += capture_rate
	// 	else if (capturing_team == TEAM_SYNDICATE)
	// 		capture_value -= capture_rate
	// 	else
	// 		return




/////////////Barricades////////////

/obj/barricade
	name = "barricade"
	desc = "A barricade. It looks like you can shoot over it and beat it down, but not walk over it. Devious."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barricade"
	density = 1
	anchored = 1.0
	flags = NOSPLASH
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	layer = OBJ_LAYER-0.1
	stops_space_move = TRUE

	var/health = 100
	var/health_max = 100

	get_desc()
		var/string = "pristine"
		if (health >= (health_max/2))
			string = "a bit scuffed"
		else
			string = "almost destroyed"

		. = "<br><span class='notice'>It looks [string].</span>"

	ex_act(severity)

		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if (!src.density || (mover.flags & TABLEPASS || istype(mover, /obj/newmeteor)) )
			return 1
		else
			return 0
	Bumped(atom/AM)
		if (istype(AM, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/V = AM
			V.health -= round(src.health/4)
			V.checkhealth()
			playsound(get_turf(src), "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
			qdel(src)
		..()

	attackby(var/obj/item/W, var/mob/user)
		attack_particle(user,src)
		take_damage(W.force)
		playsound(get_turf(src), "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 20, 1)
		user.lastattacked = src
		..()

	attack_hand(mob/user as mob)
		switch (user.a_intent)
			if (INTENT_HELP)
				visible_message(src, "<span class='notice'>[user] pats [src] [pick("earnestly", "merrily", "happily","enthusiastically")] on top.</span>")
			if (INTENT_DISARM)
				visible_message(src, "<span class='alert'>[user] tries to shove [src], but it was ineffective!</span>")
			if (INTENT_GRAB)
				visible_message(src, "<span class='alert'>[user]] tries to wrassle with [src], but it gives no ground!</span>")
			if (INTENT_HARM)
				if (ishuman(user))
					if (user.is_hulk())
						take_damage(20)
					else
						take_damage(5)
					playsound(get_turf(src), "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 25, 1)
					attack_particle(user,src)


		user.lastattacked = src
		..()

	proc/take_damage(var/damage)
		src.health -= damage

		//This works correctly because at the time of writing, these barricades cannot be repaired.
		if (health < health_max/2)
			icon_state = "barricade-damaged"

		if (health <= 0)
			qdel(src)

//barricade deployer

/obj/item/deployer/barricade
	name = "barricade deployer"
	desc = "A collection of parts that can be used to make some kind of barricade."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "barricade"
	var/object_type = /obj/barricade 		//object to deploy
	var/build_duration = 2 SECONDS

	New(loc)
		..()
		BLOCK_SETUP(BLOCK_LARGE)

	attack_self(mob/user as mob)
		SETUP_GENERIC_ACTIONBAR(user, src, build_duration, /obj/item/deployer/barricade/proc/deploy, list(user, get_turf(user)),\
		 src.icon, src.icon_state, "[user] deploys \the [src]")

	//mostly stolen from furniture_parts/proc/construct
	proc/deploy(mob/user as mob, turf/T as turf)
		var/obj/newThing = null
		if (!T)
			T = user ? get_turf(user) : get_turf(src)
			if (!T) // buh??
				return
		if (istype(T, /turf/space))
			boutput(user, "<span class='alert'>Can't build a barricade in space!</span>")
			return
		if (ispath(src.object_type))
			if (locate(src.object_type) in T.contents)
				boutput(user, "<span class='alert'>There is already a barricade here! You can't think of a way that another one could possibly fit!</span>")
				return
			newThing = new src.object_type(T)
		else
			logTheThing("diary", user, null, "tries to deploy an object of type ([src.type]) from [src] but its object_type is null and it is being deleted.", "station")
			user.u_equip(src)
			qdel(src)
			return
		if (newThing)
			if (src.material)
				newThing.setMaterial(src.material)
			if (user)
				newThing.add_fingerprint(user)
				logTheThing("station", user, null, "builds \a [newThing] (<b>Material:</b> [newThing.material && newThing.material.mat_id ? "[newThing.material.mat_id]" : "*UNKNOWN*"]) at [log_loc(T)].")
				user.u_equip(src)
		qdel(src)
		return newThing

/obj/item_dispenser/barricade
	name = "barricade dispenser"
	desc = "A storage container that easily dispenses fresh deployable barricades. It can be refilled with deployable barricades."
	icon_state = "dispenser_barricade"
	filled_icon_state = "dispenser_barricade"
	deposit_type = /obj/item/deployer/barricade
	withdraw_type = /obj/item/deployer/barricade
	amount = 50
	dispense_rate = 5 SECONDS

/obj/item_dispenser/bandage
	name = "bandage dispenser"
	desc = "A storage container that easily dispenses fresh bandage."
	icon_state = "dispenser_bandages"
	filled_icon_state = "dispenser_bandages"
	deposit_type = null
	withdraw_type = /obj/item/bandage/medicated
	cant_deposit = 1
	amount = 30
	dispense_rate = 5 SECONDS

/obj/item/bandage/medicated
	name = "medicated bandage"
	desc = "A length of gauze that will help stop bleeding and heal a small amount of brute/burn damage."
	uses = 4
	brute_heal = 10
	burn_heal = 5

/obj/machinery/chem_dispenser/medical
	name = "medical reagent dispenser"
	desc = "It dispenses chemicals. Mostly harmless ones, but who knows?"
	dispensable_reagents = list("antihol", "charcoal", "epinephrine", "mutadone", "proconvertin", "atropine",\
		"silver_sulfadiazine", "salbutamol", "anti_rad",\
		"oculine", "mannitol", "styptic_powder", "saline",\
		"salicylic_acid", "blood",\
		"menthol", "antihistamine")

	icon_state = "dispenser"
	icon_base = "dispenser"
	dispenser_name = "Medical"


/obj/machinery/chem_dispenser/medical/fortuna
	dispensable_reagents = list("antihol", "charcoal", "epinephrine", "mutadone", "proconvertin", "filgrastim", "atropine",\
	"silver_sulfadiazine", "salbutamol", "perfluorodecalin", "synaptizine", "anti_rad",\
	"oculine", "mannitol", "penteticacid", "styptic_powder", "saline",\
	"salicylic_acid", "blood", "synthflesh",\
	"menthol", "antihistamine", "smelling_salt")

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

////////////////////////////player stats tracking datum//////////////////
/datum/pw_stats_manager
	var/list/player_stats = list()			//assoc list of ckey -> /datum/pw_player_stats

	var/list/item_rewards = list()		//assoc list of item name -> amount
	var/list/crate_list = list()			//assoc list of crate tier -> amount
	var/html_string

	proc/add_item_reward(var/string, var/team_num, var/amt = 1)
		switch(team_num)
			if (TEAM_NANOTRASEN)
				string = "NT,[string]"
			if (TEAM_SYNDICATE)
				string = "SY,[string]"

		item_rewards[string] += amt

	proc/add_crate(var/string, var/team_num)
		switch(team_num)
			if (TEAM_NANOTRASEN)
				string = "NT,[string]"
			if (TEAM_SYNDICATE)
				string = "SY,[string]"

		crate_list[string] ++

	proc/add_player(var/datum/mind/mind, var/initial_name, var/team_num, var/rank)
		//only add new stat tracker datum if one doesn't exist
		if (mind.ckey && player_stats[mind.ckey] == null)
			player_stats[mind.ckey] = new/datum/pw_player_stats(mind = mind, initial_name = initial_name, team_num = team_num, rank = rank )

	//team_num = team that just captured this point
	//computer = computer object for the point that has been captured. used for distance check currently.
	proc/inc_control_point_caps(var/team_num, var/obj/computer)
		for (var/ckey in player_stats)
			var/datum/pw_player_stats/stat = player_stats[ckey]
			if (stat.team_num != team_num)
				continue
			//if they are within 30 tiles of the capture point computer, it counts as helping!
			//I do the get_turf on the current mob in case they are in a pod. This is called Pod Wars after all...
			if (get_dist(get_turf(stat.mind?.current), computer) <= 30)
				stat.control_point_capture_count ++

	proc/inc_friendly_fire(var/mob/M)
		if (!ismob(M) || !M.ckey)
			return
		var/datum/pw_player_stats/stat = player_stats[M.ckey]
		if (istype(stat))
			stat.friendly_fire_count ++

	proc/inc_death(var/mob/M)
		if (!ismob(M) || !M.ckey)
			return
		var/datum/pw_player_stats/stat = player_stats[M.ckey]
		if (istype(stat))
			stat.death_count ++

		src.inc_longest_life(M.ckey)

	//uses shift time
	//only called from inc_death and the loop through the player_stats list of pw_player_stats datum
	proc/inc_longest_life(var/ckey)
		// if (!ismob(M))
		// 	return
		var/datum/pw_player_stats/stat = player_stats[ckey]
		if (istype(stat))
			var/shift_time = round(ticker.round_elapsed_ticks / (1 MINUTES), 0.01)		//this converts shift time to "minutes". uses this cause it starts counting when the round starts, not when the lobby starts.


			//I feel like I should explain this, but I'm not gonna cause it's not confusing enough to need it. Just the long names make it look weird.
			if (!stat.longest_life)
				stat.time_of_last_death = shift_time
				stat.longest_life = shift_time
			else
				if (stat.time_of_last_death < shift_time - stat.time_of_last_death)
					stat.time_of_last_death = shift_time
					stat.longest_life = shift_time - stat.time_of_last_death

	proc/inc_farts(var/mob/M)
		if (!ismob(M) || !M.ckey)
			return
		var/datum/pw_player_stats/stat = player_stats[M.ckey]
		if (istype(stat))
			stat.farts ++

	//has a variable increment amount cause not every tic of ethanol metabolize metabolizes the same amount of alcohol.
	proc/inc_alcohol_metabolized(var/mob/M, var/inc_amt = 1)
		if (!ismob(M) || !M.ckey)
			return
		var/datum/pw_player_stats/stat = player_stats[M.ckey]
		if (istype(stat))
			stat.alcohol_metabolized += inc_amt

	//called on round end to output the stats. returns the HTML as a string.
	proc/build_HTML()

		//calculate pet survival first.
		var/pet_dat = "<h4>Pet Stats:</h4>"
		for(var/pet in by_cat[TR_CAT_PW_PETS])
			if(istype(pet, /obj/critter/turtle/sylvester/Commander))
				var/obj/critter/P = pet
				if(P.alive)
					if (istype(get_area(P), /area/pod_wars/team1))
						pet_dat += "<span class='notice'>Sylvester is safe and sound on the Pytheas! Good job NanoTrasen!</span><br>"
					else if (istype(get_area(P), /area/pod_wars/team2))
						pet_dat += "<span class='alert'>Sylvester was captured by the Syndicate! Oh no!</span><br>"
					else
						pet_dat += "<span class='notice'>Sylvester survived! Yay!</span><br>"

				else
					pet_dat += "<span class='alert'>Sylvester was killed! Oh no!</span><br>"

			else if(istype(pet, /mob/living/carbon/human/npc/monkey/oppenheimer/pod_wars))
				var/mob/living/carbon/human/opp = pet
				if (isalive(opp))
					if (istype(get_area(opp), /area/pod_wars/team2))
						pet_dat += "<span class='notice'>Oppenheimer is safe and sound on the Lodbrok! Good job Syndicates!</span><br>"
					else if (istype(get_area(opp), /area/pod_wars/team1))
						pet_dat += "<span class='alert'>Oppenheimer was captured by NanoTrasen! Oh no!</span><br>"
					else
						pet_dat += "<span class='notice'>Oppenheimer survived! Yay!</span><br>"

				else
					pet_dat += "<span class='alert'>Oppenheimer was killed! Oh no!</span><br>"

		//write the player stats as a simple table
		var/p_stat_text = ""
		for (var/ckey in player_stats)
			var/datum/pw_player_stats/stat = player_stats[ckey]
			//first update longest life
			inc_longest_life(stat.ckey)
			// p_stat_text += stat.build_text()
			p_stat_text += {"
<tr>
 <td>[stat.team_num == 1? "NT" : stat.team_num == 2 ? "SY" : ""]</td>
 <td>[stat.initial_name] ([stat.ckey])</td>
 <td>[stat.death_count]</td>
 <td>[stat.friendly_fire_count]</td>
 <td>[stat.longest_life] (min)</td>
 <td>[round(stat.alcohol_metabolized, 0.01)](u)</td>
 <td>[stat.farts]</td>
 <td>[stat.control_point_capture_count]</th>  d
</tr>"}

		return {"
<h2>
Game Stats
</h2>
[pet_dat]
<h3>
Player Stats
</h3>
<table id=\"myTable\" cellspacing=\"0\"; cellpadding=\"5\">
  <tr>
    <th>Team</th>
    <th>Name</th>
    <th>Deaths</th>
    <th>Friendly Fire</th>
    <th>Longest Life</th>
    <th>Alcohol Metabolized</th>
    <th>Farts</th>
    <th>Ctrl Pts</th>
  </tr>
[p_stat_text]</table>
<hr>
<h2>Reward Stats</h2>
<h3>Crates</h3>
[build_rewards_text(src.crate_list)]
<h3>Items</h3>
[build_rewards_text(src.item_rewards)]

<style>
* {
  box-sizing: border-box;
}

.column {
  border: 1px solid #66A;
  float: left;
  width: 50%;
  padding: 10px;
}

 body {background-color: #448;}
 h2, h3, h4, span {color:white}
 td, th
 {
  border: 1px solid #66A;
  text-align: center;
  color:white;
 }

</style>"}

	//Assumes Lists are an assoc list in the format where the key starts with either "NT," or "SY," followed by the item/crate_tier name
	//and the value stored is just an int for the amount.
	//returns html text
	proc/build_rewards_text(var/list/L)
		if (!islist(L) || !length(L))
			logTheThing("debug", null, null, "Something trying to write one of the lists for stats...")
			return

		var/cr_stats_NT = ""
		var/cr_stats_SY = ""
		for (var/stat in L)
			// message_admins("[stat]:[copytext(1,3)];[copytext(stat, 4)]")
			if (!istext(stat) || length(stat) <= 4) continue

			if (copytext(stat, 1,3) == "NT")
				cr_stats_NT += "<tr><b>[copytext(stat, 4)]</b> = [L[stat]]</tr><br>"
			else if (copytext(stat, 1,3) == "SY")
				cr_stats_SY += "<tr><b>[copytext(stat, 4)]</b> = [L[stat]]</tr><br>"

		return {"

<div class=\"column\">
  <h3>NanoTrasen</h3>
  [cr_stats_NT]
</div>
<div class=\"column\">
  <h3>Syndicate</h3>
  [cr_stats_SY]
</div>
"}

	proc/display_HTML_to_clients()
		html_string = build_HTML()
		for (var/client/C in clients)
			C.Browse(html_string, "window=scores;size=700x500;title=Scores" )
			boutput(C, "<strong style='color: #393;'>Use the command Display-Stats to view the stats screen if you missed it.</strong>")
			C.mob.verbs += /client/proc/display_stats

/client/proc/display_stats()
	set name = "Display Stats"
	var/datum/game_mode/pod_wars/mode = ticker.mode
	if (istype(mode))
		var/raw = alert(src,"Do you want to view the stats as raw html?", "Display Stats", "No", "Yes")
		if (raw == "Yes")
			src.Browse("<XMP>[mode.stats_manager?.html_string]</XMP>", "window=scores;size=700x500;title=Scores" )
		else
			src.Browse(mode.stats_manager?.html_string, "window=scores;size=700x500;title=Scores" )

//for displaying info about players on round end to everyone.
/datum/pw_player_stats
	var/datum/mind/mind
	var/initial_name
	var/ckey 			//this and initial_name are mostly for safety
	var/team_num 		//valid values, 1 = NT, 2 = SY
	var/rank			//current valid values include "Commander", "Pilot"
	var/time_of_last_death = 0

	//silly stats
	var/death_count = 0
	var/friendly_fire_count = 0
	var/control_point_capture_count = 0			//should be determined by being in the control point area when captured
	var/longest_life = 0						//this value is in "minutes" byond time.
	var/alcohol_metabolized = 0
	var/farts = 0

	New(var/datum/mind/mind, var/initial_name, var/team_num, var/rank)
		..()
		src.mind = mind
		src.initial_name = initial_name
		src.team_num = team_num
		src.rank = rank

		src.ckey = mind?.ckey


/obj/storage/secure/crate/pod_wars_rewards
	desc = "It looks like a crate of some kind, probably locked. Who can say?"
	grab_stuff_on_spawn = TRUE
	req_access = list()
	var/team_num = 0						//should be 1 or 2
	var/tier = 1							//acceptable values, 1-3.

	New(turf/loc, var/team_num, var/tier)
		..()
		src.team_num = team_num
		src.tier = tier

		showswirl(src, 0)
		playsound(loc, "sound/effects/mag_warp.ogg", 100, 1, flags = SOUND_IGNORE_SPACE)
		//handle name, color, and access for types...
		var/team_name_str
		switch(team_num)
			if (TEAM_NANOTRASEN)
				req_access = list(access_heads)
				color = "#004EFF"
				team_name_str = "NanoTrasen"
			if (TEAM_SYNDICATE)
				req_access = list(access_syndicate_shuttle)
				color = "#FF004E"
				team_name_str = "Syndicate"

		//Silly, wasn't planning to do this many, but had it keep counting up for fun. idk of an arabic to roman numeral function offhand.
		var/tier_flavor
		switch (tier)
			if (1)
				tier_flavor = "I"
			if (2)
				tier_flavor = "II"
			if (3)
				tier_flavor = "III"
			if (4)
				tier_flavor = "IV"
			if (5)
				tier_flavor = "V"
			if (6)
				tier_flavor = "VI"
			if (7)
				tier_flavor = "VII"
			if (8)
				tier_flavor = "VIII"
			if (9)
				tier_flavor = "IX"


		name = "[team_name_str] secure crate tier [tier_flavor]"
		SPAWN_DBG(1 SECONDS)
			spawn_items()

	//Selects the items that this crate spawns with based on its possible contents.
	proc/spawn_items()
		var/tier1_max_points = 25
		var/tier2_max_points = 20
		var/tier3_max_points = 15

		//This feels really stupid, but idk how better to do it. -kly
		switch (tier)
			if (1)
				make_items_in_tier(pw_rewards_tier1, tier1_max_points)
			if (2)
				make_items_in_tier(pw_rewards_tier1, tier1_max_points/2)
				make_items_in_tier(pw_rewards_tier2, tier2_max_points)

			if (3)
				make_items_in_tier(pw_rewards_tier1, tier1_max_points/3)
				make_items_in_tier(pw_rewards_tier2, tier2_max_points/2)
				make_items_in_tier(pw_rewards_tier3, tier3_max_points)
			else
				//All "higher" tiers. I guess they'll be about the same, give em a little something to incentivize holding onto em for longer...
				make_items_in_tier(pw_rewards_tier1, tier1_max_points/2)
				make_items_in_tier(pw_rewards_tier2, tier2_max_points)
				make_items_in_tier(pw_rewards_tier3, tier3_max_points)


	//makes the items in the crate randomly picking from a rewards list,
	proc/make_items_in_tier(var/list/possible_rewards, var/max_points)
		if (!islist(possible_rewards) || length(possible_rewards) == 0)
			return 0

//Kinda cheesey here with the map defs, but I'm too lazy to care. makes a temp var for the mode, if it's not the right type (which idk why it wouldn't be)
//then it is null so that the ?. will fail. So it still works regardless of mode, not that it would have the populated rewards lists if the mdoe was wrong...
		var/datum/game_mode/pod_wars/mode = ticker.mode
		if (!istype(mode))
			mode = null
		var/failsafe_counter = 0		//I'm paranoid okay... what if some admin accidentally fucks with the list, could hang the server.
		var/points = 0
		while (points < max_points)
			var/selected = pick(possible_rewards)
			var/point_val = possible_rewards[selected]
			if(points + point_val > max_points + 5) continue
			var/obj/item/I = new selected(src)

			// message_admins("[I.name] = [possible_rewards[selected]]pts")
			//if possible_rewards[selected] is null or 0, we increment by 1 null or 1 we spawn 1, if some other number, we add that many points
			points += point_val ? point_val : 1
			// points += total_spawned

			failsafe_counter++
			if (failsafe_counter > 100)
				break

			mode?.stats_manager.add_item_reward(I.name, team_num)
		mode?.stats_manager.add_crate(src.name, team_num)
		return 1

//this is global so admins can run this proc to spawn the crates if they like, idk why they'd really want to but might as well be safe.
//The list here is set up where the object path is the key, and the value is its point amount
proc/setup_pw_crate_lists()
	pw_rewards_tier1 = list(/obj/item/storage/firstaid/regular = 1, /obj/item/reagent_containers/mender/both = 1, 	///obj/item/tank/plasma = 2
		/obj/item/tank/oxygen = 1, /obj/item/storage/box/energy_frag = 4, /obj/item/storage/box/energy_concussion = 4, /obj/item/device/flash = 2, /obj/item/deployer/barricade = 4,
		/obj/item/shipcomponent/mainweapon/taser = 3, /obj/item/shipcomponent/mainweapon/laser/short = 3,/obj/item/ammo/power_cell/high_power = 5,
		/obj/item/material_piece/steel{amount=10} = 1, /obj/item/material_piece/copper{amount=10} = 1, /obj/item/material_piece/glass{amount=10} = 1)

	pw_rewards_tier2 = list(/obj/item/tank/jetpack = 1, /obj/item/old_grenade/smoke = 2,/obj/item/chem_grenade/flashbang = 2, /obj/item/barrier = 1,
		/obj/item/old_grenade/emp = 3, /obj/item/sword/discount = 4, /obj/item/storage/firstaid/crit = 1, /obj/item/wrench/battle = 1, /obj/item/dagger/syndicate/specialist = 2,
		/obj/item/shipcomponent/mainweapon/mining = 2, /obj/item/shipcomponent/mainweapon/laser = 4, /obj/item/shipcomponent/mainweapon/disruptor_light = 4,/obj/item/ammo/power_cell/higher_power = 3, /obj/item/ammo/power_cell/self_charging/pod_wars_standard = 3,
		/obj/item/material_piece/cerenkite{amount=5} = 1, /obj/item/material_piece/claretine{amount=5} = 1, /obj/item/material_piece/bohrum{amount=10} = 1, /obj/item/material_piece/plasmastone{amount=10} = 1, /obj/item/material_piece/uqill{amount=10} = 1, /obj/item/material_piece/telecrystal{amount=10})

	pw_rewards_tier3 = list(/obj/item/gun/energy/crossbow = 1, /obj/item/cloak_gen = 1, /obj/item/device/chameleon = 1,
		/obj/item/gun/flamethrower/backtank = 3, /obj/item/ammo/power_cell/self_charging/pod_wars_high = 2,
		/obj/item/shipcomponent/mainweapon/russian = 3, /obj/item/shipcomponent/mainweapon/disruptor = 3, /obj/item/shipcomponent/mainweapon/laser_ass = 4, /obj/item/shipcomponent/mainweapon/rockdrills = 4,
		/obj/item/material_piece/iridiumalloy{amount=4} = 1, /obj/item/material_piece/erebite{amount=10} = 1, /obj/item/raw_material/starstone{amount=2} = 1, /obj/item/raw_material/miracle{amount=10} = 1)


// var/list/item_tier_low = list(/obj/item/storage/firstaid/regular, /obj/item/storage/firstaid/crit, /obj/item/reagent_containers/mender/both, 	///obj/item/tank/plasma
// /obj/item/tank/oxygen,/obj/item/old_grenade/smoke,/obj/item/chem_grenade/flashbang)
// var/list/item_tier_med = list(/obj/item/tank/jetpack,)
// var/list/item_tier_high = list()

// Low Tier: Blaster (team colored), EMP Grenade (mega situational, after all), flashbang, regular flash, pocket oxy tank
// Medium Tier: dsaber, Revolver, Cloaking Field Projector, Radbow, pickpocket gun??, maybe other traitor or rare gear, jetpack
// High tier: csaber Stims, Cloaker, Deployable team oriented turret (limited ammo and can be destroyed),


//This is dumb. I should really have these all be one object, but I figure we might wanna specifically admin spawn thse from time to time. -kyle

/obj/storage/secure/crate/pod_wars_rewards/nanotrasen
	req_access = list(access_heads)
	team_num = 1		//should be 1 or 2
	tier = 1			//acceptable values, 1-3.

	medium
		tier = 2
	high
		tier = 3
/obj/storage/secure/crate/pod_wars_rewards/syndicate
	req_access = list(access_syndicate_shuttle)
	team_num = 2		//should be 1 or 2
	tier = 1			//acceptable values, 1-3.

	medium
		tier = 2
	high
		tier = 3

//basically like stinger in that it shoots projectiles, but has no explosions, different icon
/obj/item/old_grenade/energy_frag
	name = "blast grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "energy_stinger"
	det_time = 30.0
	org_det_time = 30
	alt_det_time = 60
	item_state = "fragnade"
	is_syndicate = 0
	sound_armed = "sound/weapons/armbomb.ogg"
	icon_state_armed = "energy_stinger1"
	var/datum/projectile/custom_projectile_type = /datum/projectile/laser/blaster/blast
	var/pellets_to_fire = 10

	prime()
		var/turf/T = ..()
		if (T)
			playsound(T, "sound/weapons/grenade.ogg", 25, 1)
			var/datum/projectile/special/spreader/uniform_burst/circle/PJ = new(T)
			PJ.pellets_to_fire = src.pellets_to_fire
			if(src.custom_projectile_type)
				PJ.spread_projectile_type = src.custom_projectile_type
				PJ.pellet_shot_volume = 75 / PJ.pellets_to_fire
			message_admins(initial(custom_projectile_type.power))
			//if you're on top of it, eat all the shots. Deal 1/4 damage per shot. Doesn't make sense logically, but w/e.
			var/mob/living/L = locate(/mob/living) in get_turf(src)
			if (istype(L))

				// var/datum/projectile/P = new PJ.spread_projectile_type		//dummy projectile to get power level
				L.TakeDamage("chest", 0, ((initial(custom_projectile_type.power)/4)*pellets_to_fire)/L.get_ranged_protection(), 0, DAMAGE_BURN)
				L.emote("twitch_v")
			else
				shoot_projectile_ST(get_turf(src), PJ, get_step(src, NORTH))
			SPAWN_DBG(0.1 SECONDS)
				qdel(src)
		else
			qdel(src)
		return

/obj/item/storage/box/energy_frag
	name = "\improper blast grenade box"
	desc = "A box with 5 blast grenade."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/old_grenade/energy_frag = 5)

/obj/item/old_grenade/energy_concussion
	name = "concussion grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "concussion"
	det_time = 30.0
	org_det_time = 30
	alt_det_time = 60
	item_state = "fragnade"
	is_syndicate = 0
	sound_armed = "sound/weapons/armbomb.ogg"
	icon_state_armed = "concussion1"

	prime()
		var/turf/T = ..()
		if (T)
			playsound(T, "sound/weapons/grenade.ogg", 25, 1)
			var/obj/overlay/O = new/obj/overlay(get_turf(T))
			O.anchored = 1
			O.name = "Explosion"
			O.layer = NOLIGHT_EFFECTS_LAYER_BASE
			O.icon = 'icons/effects/64x64.dmi'
			O.icon_state = "explo_energy"
			O.pixel_x = -16
			O.pixel_y = -16

			//if you're on the tile directly.
			var/mob/living/L = locate(/mob/living) in get_turf(src)
			if (istype(L))
				L.do_disorient(stamina_damage = 120, weakened = 60, stunned = 0, disorient = 0, remove_stamina_below_zero = 0)
				L.TakeDamage("chest", rand(20, 40)/L.get_melee_protection(), 0, 0, DAMAGE_BLUNT)
				L.emote("twitch_v")
			else

				for (var/atom/movable/A in orange(src, 3))
					var/turf/target = get_ranged_target_turf(A, get_dir(T, A), 10)
					//eh, another typecheck, no way around it I don't think. unless we wanna apply the status effect directly? idk.
					if (isliving(A))
						var/mob/living/M = A
						M.do_disorient(stamina_damage = 60, weakened = 30, stunned = 0, disorient = 20, remove_stamina_below_zero = 0)
					if (target)
						A.throw_at(target, 10 - get_dist(src, A)*2, 1)		//throw things farther if they are closer to the epicenter.

			SPAWN_DBG(0.1 SECONDS)
				qdel(O)
				qdel(src)
		else
			qdel(src)
		return

/obj/item/storage/box/energy_concussion
	name = "\improper concussion grenade box"
	desc = "A box with 5 concussion grenade."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/old_grenade/energy_concussion = 5)

///////////////////////////////////////PW Blasters
/obj/item/gun/energy/blaster_pod_wars
	name = "blaster pistol"
	desc = "A dangerous-looking blaster pistol. It's self-charging by a radioactive power cell."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "pw_pistol"
	item_state = "pw_pistol_nt"
	w_class = 3.0
	force = 8.0
	mats = 0

	var/image/indicator_display = null
	var/display_color =	"#00FF00"
	var/initial_proj = /datum/projectile/laser/blaster
	var/team_num = 0	//1 is NT, 2 is Syndicate

	shoot(var/target,var/start,var/mob/user)
		if (canshoot())
			if (team_num)
				if (team_num == 1 && user?.mind?.special_role == "NanoTrasen")
					return ..(target, start, user)
				else if (team_num == 2 && user?.mind?.special_role == "Syndicate")
					return ..(target, start, user)
				else
					boutput(user, "<span class='alert'>You don't have to right DNA to fire this weapon!</span><br>")
					playsound(get_turf(user), "sound/machines/buzz-sigh.ogg", 20, 1)

					return
			else
				return ..(target, start, user)

	disposing()
		indicator_display = null
		..()


	New()
		var/obj/item/ammo/power_cell/self_charging/pod_wars_basic/PC = new/obj/item/ammo/power_cell/self_charging/pod_wars_basic()
		cell = PC
		current_projectile = new initial_proj
		projectiles = list(current_projectile)
		src.indicator_display = image('icons/obj/items/gun.dmi', "")
		..()


	update_icon()
		..()
		// src.overlays = null

		if (src.cell)
			var/maxCharge = (src.cell.max_charge > 0 ? src.cell.max_charge : 0)
			var/ratio = min(1, src.cell.charge / maxCharge)
			ratio = round(ratio, 0.25) * 100
			if (ratio == 0)
				return
			indicator_display.icon_state = "pw_pistol_power-[ratio]"
			indicator_display.color = display_color
			UpdateOverlays(indicator_display, "ind_dis")

	nanotrasen
		muzzle_flash = "muzzle_flash_plaser"
		display_color =	"#3d9cff"
		item_state = "pw_pistol_nt"
		initial_proj = /datum/projectile/laser/blaster/pod_pilot/blue_NT
		team_num = 1

	syndicate
		muzzle_flash = "muzzle_flash_laser"
		display_color =	"#ff4043"
		item_state = "pw_pistol_sy"
		initial_proj = /datum/projectile/laser/blaster/pod_pilot/red_SY
		team_num = 2

/obj/item/ammo/power_cell/higher_power
	name = "Power Cell - 500"
	desc = "A power cell that holds a max of 500PU"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	m_amt = 20000
	g_amt = 45000
	charge = 500.0
	max_charge = 500.0


/obj/item/ammo/power_cell/self_charging/pod_wars_basic
	name = "Power Cell - Basic Radioisotope"
	desc = "A power cell that contains a radioactive material and small capacitor that recharges at a modest rate. Holds 200PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 200
	max_charge = 200
	recharge_rate = 10

/obj/item/ammo/power_cell/self_charging/pod_wars_standard
	name = "Power Cell - Standard Radioisotope"
	desc = "A power cell that contains a radioactive material that recharges at a quick rate. Holds 300PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 300
	max_charge = 300
	recharge_rate = 15

/obj/item/ammo/power_cell/self_charging/pod_wars_high
	name = "Power Cell - Robust Radioisotope "
	desc = "A power cell that contains a radioactive material and large capacitor that recharges at a modest rate. Holds 350PU."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "recharger_cell"
	charge = 350
	max_charge = 350
	recharge_rate = 30


/proc/make_fake_explosion(var/atom/I)
	var/obj/overlay/O = new/obj/overlay(get_turf(I))
	O.anchored = 1
	O.name = "Explosion"
	O.layer = NOLIGHT_EFFECTS_LAYER_BASE
	O.pixel_x = -92
	O.pixel_y = -96
	O.icon = 'icons/effects/214x246.dmi'
	O.icon_state = "explosion"
	SPAWN_DBG(3.5 SECONDS)
		qdel(O)

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
