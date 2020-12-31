#define TEAM_NANOTRASEN 1
#define TEAM_SYNDICATE 2
/datum/game_mode/pod_wars
	name = "pod wars"
	config_tag = "pod_wars"
	votable = 1
	probability = 0 // Overridden by the server config. If you don't have access to that repo, keep it 0.
	crew_shortage_enabled = 0

	shuttle_available = 0 // 0: Won't dock. | 1: Normal. | 2: Won't dock if called too early.
	list/latejoin_antag_roles = list() // Unrecognized roles default to traitor in mob/new_player/proc/makebad().
	do_antag_random_spawns = 0
	var/list/frequencies_used = list()


	var/datum/pod_wars_team/team_NT
	var/datum/pod_wars_team/team_SY

	var/obj/screen/score_board/board
	var/round_limit = 35 MINUTES
	var/force_end = 0

/datum/game_mode/pod_wars/announce()
	boutput(world, "<B>The current game mode is - Pod Wars!</B>")
	boutput(world, "<B>Two starships of similar technology and crew compliment warped into the same asteroid field!</B>")
	boutput(world, "<B>Mine materials, build pods, kill enemies, destroy the enemy mothership!</B>")

//setup teams and commanders
/datum/game_mode/pod_wars/pre_setup()
	board = new()
	if (!setup_teams())
		return 0

	//just to move the bar to the right place.
	handle_point_change(team_NT, team_NT.points)	//HAX. am
	handle_point_change(team_SY, team_SY.points)	//HAX. am

	return 1


/datum/game_mode/pod_wars/proc/setup_teams()
	team_NT = new/datum/pod_wars_team(mode = src, team = 1)
	team_SY = new/datum/pod_wars_team(mode = src, team = 2)

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
			if (prob(100))	//change to 50 - KYLE
				team_NT.accept_initial_players(readied_minds)
			else
				team_SY.accept_initial_players(readied_minds)

		else
			var/half = round(length/2)
			team_NT.accept_initial_players(readied_minds.Copy(1, half+1))
			team_SY.accept_initial_players(readied_minds.Copy(half+1, 0))

	return 1

/datum/game_mode/pod_wars/proc/add_latejoin_to_team(var/datum/mind/mind, var/datum/job/JOB)
	if (istype(JOB, /datum/job/pod_wars/nanotrasen))
		team_NT.members += mind
		team_NT.equip_player(mind.current)
	else if (istype(JOB, /datum/job/pod_wars/syndicate))
		team_SY.members += mind
		team_SY.equip_player(mind.current)

#ifdef MAP_OVERRIDE_POD_WARS
	for(var/turf/T in landmarks[LANDMARK_LATEJOIN])
		if (istype(T.loc, /area/podmode/team1))
			mind.current.set_loc(T)
			return
		else if (istype(T.loc, /area/podmode/team2))
			mind.current.set_loc(T)
			return
#endif

/datum/game_mode/pod_wars/post_setup()
	SPAWN_DBG(-1)
		setup_asteroid_ores()

	if(round_limit > 0)
		SPAWN_DBG (round_limit) // this has got to end soon
			command_alert("Something something radiation.","Emergency Update")
			sleep(6000) // 10 minutes to clean up shop
			command_alert("Revolution heads have been identified. Please stand by for hostile employee termination.", "Emergency Update")
			sleep(3000) // 5 minutes until everyone dies
			command_alert("You may feel a slight burning sensation.", "Emergency Update")
			sleep(10 SECONDS) // welp
			for(var/mob/living/carbon/M in mobs)
				M.gib()
			force_end = 1


/datum/game_mode/pod_wars/proc/setup_asteroid_ores()

//	var/list/types = list("mauxite", "pharosium", "molitz", "char", "ice", "cobryl", "bohrum", "claretine", "viscerite", "koshmarite", "syreline", "gold", "plasmastone", "cerenkite", "miraclium", "nanite cluster", "erebite", "starstone")
//	var/list/weights = list(100, 100, 100, 125, 55, 55, 25, 25, 55, 40, 20, 20, 15, 20, 10, 1, 5, 2)

	var/datum/ore_cluster/minor/minor_ores = new /datum/ore_cluster/minor
	for(var/area/podmode/asteroid/minor/A in world)
		if(!istype(A, /area/podmode/asteroid/minor/nospawn))
			for(var/turf/simulated/wall/asteroid/pod_wars/AST in A)
				//Do the ore_picking
				AST.randomize_ore(minor_ores)

	var/list/datum/ore_cluster/oreClusts = list()
	for(var/OC in concrete_typesof(/datum/ore_cluster))
		oreClusts += new OC

	for(var/area/podmode/asteroid/major/A in world)
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
/datum/game_mode/pod_wars/on_human_death(var/mob/M)
	var/nt = locate(M.mind) in team_NT.members
	if (nt)
		if (M.mind == team_NT.commander)
			team_NT.change_points(-1)
		team_SY.change_points(1)

		return
	var/sy = locate(M.mind) in team_SY.members
	if (sy)
		if (M.mind == team_SY.commander)
			team_SY.change_points(-1)
		team_NT.change_points(1)


/datum/game_mode/pod_wars/proc/announce_critical_system_destruction(var/team_num, var/obj/pod_base_critical_system/CS)
	var/name
	if (team_num == TEAM_NANOTRASEN)
		name = "NanoTrasen"
		src.team_NT.change_points(-25)
	else if (team_num == TEAM_SYNDICATE)
		name = "The Syndicate"
		src.team_SY.change_points(-25)

	boutput(world, "<h2><span class='alert'>[name]'s [CS] has been destroyed!!</span></h2>")

/datum/game_mode/pod_wars/proc/announce_critical_system_damage(var/team_num, var/obj/pod_base_critical_system/CS)
	var/datum/pod_wars_team/team
	if (team_num == TEAM_NANOTRASEN)
		team = team_NT
	else if (team_num == TEAM_SYNDICATE)
		team = team_SY

	// for (var/datum/mind/M in team.members)
	// 	if (M.current)
	// 		boutput(M.current, "<h3><span class='alert'>Your team's [CS] is under attack!</span></h3>")
	boutput(world, "<h3><span class='alert'>[team.name]'s <b>[CS]<b> is under attack!</span></h3>")



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

/datum/game_mode/pod_wars/declare_completion()
	var/datum/pod_wars_team/winner = team_NT.points > team_SY.points ? team_NT.name : team_SY.name
	var/datum/pod_wars_team/loser = team_NT.points < team_SY.points ? team_NT.name : team_SY.name
	// var/text = ""
	boutput(world, "<FONT size = 2><B>The winner was the [winner.name], commanded by [winner.commander.current]:</B></FONT><br>")
	boutput(world, "<FONT size = 2><B>The loser was the [loser.name], commanded by [loser.commander.current]:</B></FONT><br>")

	// for(var/datum/mind/leader_mind in commanders)

	..() // Admin-assigned antagonists or whatever.


/datum/pod_wars_team
	var/name = "NanoTrasen"
	var/comms_frequency = 0
	var/area/base_area = null		//base ship area
	var/datum/mind/commander = null
	var/list/members = list()
	var/team_num = 0

	var/points = 100
	var/max_points = 200
	var/list/mcguffins = list()		//Should have 4 AND ONLY 4
	var/datum/game_mode/pod_wars/mode

	New(var/datum/game_mode/pod_wars/mode, team)
		..()
		src.mode = mode
		src.team_num = team
		if (team_num == TEAM_NANOTRASEN)
			name = "NanoTrasen"
#ifdef MAP_OVERRIDE_POD_WARS
			base_area = /area/podmode/team1 //area north, NT crew
#endif
		else if (team_num == TEAM_SYNDICATE)
			name = "Syndicate"
#ifdef MAP_OVERRIDE_POD_WARS
			base_area = /area/podmode/team2 //area south, Syndicate crew
#endif
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
		select_commander()

		for (var/datum/mind/M in players)
			equip_player(M.current)
			M.current.antagonist_overlay_refresh(1,0)

	proc/select_commander()
		var/list/possible_commanders = get_possible_commanders()
		if (isnull(possible_commanders) || !possible_commanders.len)
			return 0

		commander = pick(possible_commanders)
		// commander.special_role = "commander"
		return 1

//Really stolen from gang, But this basically just picks everyone who is ready and not hellbanned or jobbanned from Command or Captain
	proc/get_possible_commanders()
		var/list/candidates = list()
		for(var/datum/mind/mind in members)
			var/mob/new_player/M = mind.current
			if (!istype(M)) continue
			if (ishellbanned(M)) continue
			if(jobban_isbanned(M, "Captain")) continue //If you can't captain a Space Station, you probably can't command a starship either...
			if(jobban_isbanned(M, "NanoTrasen Commander") || ("NanoTrasen Commander" in M.client.preferences.jobs_unwanted)) continue
			if(jobban_isbanned(M, "Syndicate Commander") || ("Syndicate Commander" in M.client.preferences.jobs_unwanted)) continue
			if ((M.ready) && !candidates.Find(M.mind))
				candidates += M.mind

		if(candidates.len < 1)
			return null
		else
			return candidates

	proc/equip_player(var/mob/M)
		var/mob/living/carbon/human/H = M
		var/datum/job/pod_wars/JOB

		if (team_num == TEAM_NANOTRASEN)
			if (M.mind == commander)
				JOB = new /datum/job/pod_wars/nanotrasen/commander
			else
				JOB = new /datum/job/pod_wars/nanotrasen
		else if (team_num == TEAM_SYNDICATE)
			if (M.mind == commander)
				JOB = new /datum/job/pod_wars/syndicate/commander
			else
				JOB = new /datum/job/pod_wars/syndicate

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

		else if (istype(H))
			H.Equip_Job_Slots(JOB)
			JOB.special_setup(H)

		if (!ishuman(H))
			boutput(H, "something went wrong. Horribly wrong.")
			return

		H.set_clothing_icon_dirty()
		// H.set_loc(pick(pod_pilot_spawns[team_num]))
		boutput(H, "You're in the [name] faction!")
		// bestow_objective(player,/datum/objective/battle_royale/win)
		// SHOW_TIPS(H)

/obj/pod_base_critical_system
	name = "Critical System"
	icon = 'icons/obj/64x64.dmi'
	icon_state = "critical_system"
	anchored = 1
	density = 1
	bound_width = 64
	bound_height = 64

	var/health = 1000
	var/health_max = 1000
	var/team_num		//used for getting the team datum, this is set to 1 or 2 in the map editor. 1 = NT, 2 = Syndicate
	var/suppress_damage_message = 0

	New()
		..()

	disposing()
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			//get the team datum from its team number right when we allocate points.
			var/datum/game_mode/pod_wars/mode = ticker.mode

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
		if(src.material) src.material.triggerOnBullet(src, src, P)
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

		take_damage(damage*damage_mult)
		return

	attackby(var/obj/item/W, var/mob/user)
		..()
		take_damage(W.force)
		user.lastattacked = src

	get_desc()
		. = "<br><span class='notice'>It looks like it has [health] left out of [health_max]. You can just tell.</span>"

	proc/take_damage(var/damage)
		if (damage > 0)
			src.health -= damage

			if (!suppress_damage_message && istype(ticker.mode, /datum/game_mode/pod_wars))
				//get the team datum from its team number right when we allocate points.
				var/datum/game_mode/pod_wars/mode = ticker.mode

				mode.announce_critical_system_damage(team_num, src)
				suppress_damage_message = 1
				SPAWN_DBG(2 MINUTES)
					suppress_damage_message = 0


		if (health <= 0)
			qdel(src)

//////////////special clone pod///////////////

/obj/machinery/clonepod/pod_wars
	name = "Cloning Pod Deluxe"
	meat_level = 1.#INF
	var/last_check = 0
	var/check_delay = 10 SECONDS
	var/team_num		//used for getting the team datum, this is set to 1 or 2 in the map editor. 1 = NT, 2 = Syndicate
	var/datum/pod_wars_team/team

	process()

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

	proc/growclone_a_ghost()
		var/list/to_search
		if (istype(team))
			to_search = team.members
		else
			return

		for(var/datum/mind/mind in to_search)
			var/mob/dead/observer/ghost = mind.current
			if(istype(ghost) && ghost.client && !mind.dnr)
				var/success = growclone(ghost, ghost.real_name, mind)
				if (success && team)
					SPAWN_DBG(1)
						team.equip_player(src.occupant)
				break


//////////////////SCOREBOARD STUFF//////////////////
obj/screen/score_board
	name = "Score"
	desc = ""
	icon = 'icons/misc/128x32.dmi'
	icon_state = "pw_backboard"
	screen_loc = "NORTH, CENTER"
	var/obj/screen/border = null
	var/obj/screen/pw_score_bar/bar_NT = null
	var/obj/screen/pw_score_bar/bar_SY = null
	var/theme = null
	alpha = 150

	New()
		..()
		border = new(src)
		border.name = "border"
		border.icon = icon
		border.icon_state = "pw_border"
		border.vis_flags = VIS_INHERIT_ID

		bar_NT = new /obj/screen/pw_score_bar/nt(src)
		bar_SY = new /obj/screen/pw_score_bar/sy(src)

		src.vis_contents += bar_NT
		src.vis_contents += bar_SY
		src.vis_contents += border

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

/obj/screen/pw_score_bar
	icon = 'icons/misc/128x32.dmi'
	desc = ""
	vis_flags = VIS_INHERIT_ID
	var/points = 50
	var/max_points = 100

/obj/screen/pw_score_bar/nt
	name = "NanoTrasen Points"
	icon_state = "pw_nt"

/obj/screen/pw_score_bar/sy
	name = "Syndicate Points"
	icon_state = "pw_sy"


/obj/item/turret_deployer/pod_wars
	name = "Turret Deployer"
	desc = "A turret deployment thingy. Use it in your hand to deploy."
	icon_state = "st_deployer"
	w_class = 4
	health = 125
	quick_deploy_fuel = 2
	var/turret_path = /obj/deployable_turret/pod_wars

	//this is a band aid cause this is broke, delete this override when merged properly and fixed.
	attackby(obj/item/W, mob/user)
		user.lastattacked = src
		..()

	spawn_turret(var/direct)
		var/obj/deployable_turret/turret = new turret_path(src.loc,direction=direct)
		turret.health = src.health
		//turret.emagged = src.emagged
		turret.damage_words = src.damage_words
		turret.quick_deploy_fuel = src.quick_deploy_fuel
		return turret

/obj/deployable_turret/pod_wars
	name = "Ship Defense Turret"
	desc = "A ship defense turret."
	health = 250
	max_health = 250
	wait_time = 20 //wait if it can't find a target
	range = 8 // tiles
	burst_size = 3 // number of shots to fire. Keep in mind the bullet's shot_count
	fire_rate = 3 // rate of fire in shots per second
	angle_arc_size = 180
	quick_deploy_fuel = 2
	var/deployer_path = /obj/deployable_turret/pod_wars
	var/destroyed = 0

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
			sleep(5 MINUTES)
			src.opacity = 1
			src.alpha = 255
			health = initial(health)
			destroyed = 0
			active = 1

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
	projectile_type = /datum/projectile/laser/blaster/pod_pilot/blue_NT
	current_projectile = new/datum/projectile/laser/blaster/pod_pilot/blue_NT
	icon_tag = "nt"

	is_friend(var/mob/living/C)
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
	projectile_type = /datum/projectile/laser/blaster/pod_pilot/red_SY
	current_projectile = new/datum/projectile/laser/blaster/pod_pilot/red_SY
	icon_tag = "st"

	is_friend(var/mob/living/C)
		if (C.mind?.special_role == "Syndicate")
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
			if("NT Commander")
				return TEAM_NANOTRASEN
			if("NT Pilot")
				return TEAM_NANOTRASEN
			if("Syndicate Commander")
				return TEAM_SYNDICATE
			if("Syndicate Pilot")
				return TEAM_SYNDICATE
		return -1

//emergency Fabs

ABSTRACT_TYPE(/obj/machinery/macrofab/pod_wars)
/obj/machinery/macrofab/pod_wars
	name = "Emergency Pod Fabricator"
	desc = "A sophisticated machine that fabricates short-range emergency pods from a nearby reserve of supplies."
	createdObject = /obj/machinery/vehicle/arrival_pod
	itemName = "emergency pod"

	nanotrasen
		createdObject = /obj/machinery/vehicle/pod_wars_dingy/nanotrasen

	syndicate
		createdObject = /obj/machinery/vehicle/pod_wars_dingy/syndicate

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

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)
	syndicate
		icon_state = "surv_machete_st"

/obj/table/wood/round/champagne
	name = "champagne table"
	desc = "It makes champagne. Who ever said spontanious generation was false?"
	var/to_spawn = /obj/item/reagent_containers/food/drinks/bottle/champagne

	New()
		..()
		var/turf/T
		while (1)
			T = get_turf(src)
			if (!locate(to_spawn) in T.contents)
				var/obj/item/champers = new /obj/item/reagent_containers/food/drinks/bottle/champagne(T)
				champers.pixel_y = 10
			sleep(10 SECONDS)




/obj/machinery/manufacturer/pod_wars
	name = "Ship Component Fabricator"
	desc = "A manufacturing unit calibrated to produce parts for ships."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resource_amt = 20
	free_resources = list(
		/obj/item/material_piece/mauxite,
		/obj/item/material_piece/pharosium,
		/obj/item/material_piece/molitz
	)
	available = list(
		/datum/manufacture/putt/engine,
		/datum/manufacture/putt/boards,
		/datum/manufacture/putt/control,
		/datum/manufacture/putt/parts,
		/datum/manufacture/pod/boards,
		/datum/manufacture/pod/control,
		/datum/manufacture/pod/parts,
		/datum/manufacture/pod/engine,
		/datum/manufacture/pod/lock,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/cargohold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser
	)

	New()
		add_team_armor()
		..()

	proc/add_team_armor()
		return
		
/obj/machinery/manufacturer/pod_wars/nanotrasen
	name = "NanoTrasen Ship Component Fabricator"
	add_team_armor()
		available += list(
		/datum/manufacture/pod_wars/pod/armor_light/nt,
		/datum/manufacture/pod_wars/pod/armor_robust/nt
		)
/obj/machinery/manufacturer/pod_wars/syndicate
	name = "Syndicate Ship Component Fabricator"
	add_team_armor()
		available += list(
		/datum/manufacture/pod_wars/pod/armor_light/sy,
		/datum/manufacture/pod_wars/pod/armor_robust/sy
		)

////////////////pod-weapons//////////////////
/datum/manufacture/pod/weapon/mining
	name = "Mining Phaser System"
	item_paths = list("MET-1","CON-1")
	item_amounts = list(10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/bad_mining)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/taser
	name = "Mk.1 Combat Taser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(10,10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/taser)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/laser
	name = "Mk.2 Scout Laser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(10,10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser)
	time = 10 SECONDS
	create  = 1
	category = "Tool"
/datum/manufacture/pod/weapon/laser/short
	name = "Mk.2 CQ Laser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(10,10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser/short)
	time = 10 SECONDS

/datum/manufacture/pod/weapon/disruptor
	name = "Heavy Disruptor Array"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(10,10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/disruptor_light)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/disruptor/light
	name = "Mk.3 Disruptor"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(10,10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/disruptor)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/ass_laser
	name = "Mk.4 Assault Laser"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(10,10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser_ass)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

////////////pod-armor///////////////////////
/datum/manufacture/pod_wars/pod/armor_light
	name = "Light NT Pod Armor"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(30,20)
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


/datum/manufacture/pod_wars/jetpack
	name = "Jetpack"
	item_paths = list("MET-3","CON-1")
	item_amounts = list(20,30)
	item_outputs = list(/obj/item/tank/jetpack)
	time = 60 SECONDS
	create = 1
	category = "Clothing"
	
/obj/machinery/manufacturer/mining/pod_wars
	New()
		available -= /datum/manufacture/jetpack
		available += /datum/manufacture/pod_wars/jetpack
		..()


//It's cheap, use it!
/datum/manufacture/pod_wars/lock
	name = "Pod Lock (ID Card)"
	item_paths = list("MET-1")
	item_names = list("Metal")
	item_amounts = list(1)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/lock/pw_id)
	time = 1 SECONDS
	create = 1
	category = "Miscellaneous"

/////////////////////////////////////////////////
///////////////////ABILITY HOLDER////////////////
/////////////////////////////////////////////////

//stole this from vampire. prevents runtimes. IDK why this isn't in the parent.
/obj/screen/ability/topBar/pod_pilot
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
		var/obj/screen/ability/topBar/pod_pilot/B = new /obj/screen/ability/topBar/pod_pilot(null)
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
			src.object = new /obj/screen/ability/topBar/pod_pilot()
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
