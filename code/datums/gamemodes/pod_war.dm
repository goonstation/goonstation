#define TEAM_NANOTRASEN 1
#define TEAM_SYNDICATE 2
/datum/game_mode/pod_war
	name = "pod war"
	config_tag = "pod_war"
	votable = 1
	probability = 0 // Overridden by the server config. If you don't have access to that repo, keep it 0.
	crew_shortage_enabled = 1

	shuttle_available = 0 // 0: Won't dock. | 1: Normal. | 2: Won't dock if called too early.
	list/latejoin_antag_roles = list() // Unrecognized roles default to traitor in mob/new_player/proc/makebad().
	do_antag_random_spawns = 0
	var/list/frequencies_used = list()


	var/datum/pod_wars_team/team_NT
	var/datum/pod_wars_team/team_SY



/datum/game_mode/pod_war/announce()
	boutput(world, "<B>The current game mode is - Pod War!</B>")
	boutput(world, "<B>Two starships of similar technology and crew compliment warped into the same asteroid field!</B>")
	boutput(world, "<B>Mine materials, build pods, kill enemies, destroy the enemy mothership!</B>")

//setup teams and commanders
/datum/game_mode/pod_war/pre_setup()
	if (!setup_teams())
		return 0


	return 1



/datum/game_mode/pod_war/proc/setup_teams()
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
			if (prob(50))
				team_NT.accept_players(readied_minds)
			else
				team_SY.accept_players(readied_minds)

		else
			var/half = round(length/2)
			team_NT.accept_players(readied_minds.Copy(1, half))
			team_SY.accept_players(readied_minds.Copy(half+1, length))

	return 1



/datum/game_mode/pod_war/post_setup()
	// for (var/datum/mind/leaderMind in commanders)
	// 	if (!leaderMind.current)
	// 		continue

	// 	create_team(leaderMind)
	// 	bestow_objective(leaderMind,/datum/objective/specialist/pod_war)
	// 	boutput(leaderMind.current, "<h1><font color=red>You are the Commander of your starship! Organize your crew fight for survival!</font></h1>")
	// 	equip_commander(leaderMind.current)

	//Create teams
	//Setup critical systems for each starship.

	return 1

/datum/game_mode/pod_war/proc/handle_point_change()

/datum/game_mode/pod_war/proc/announce_critical_system_destruction(var/obj/pod_carrier_critical_system/CS)
	if (!istype(CS))
		return 0

	world << ("<h2><span class='alert'>[CS?.team?.name]'s [CS] has been destroyed!!</span></h2>")




/datum/game_mode/pod_war/check_finished()


 return 0

/datum/game_mode/pod_war/process()
	..()

/datum/game_mode/pod_war/declare_completion()

	// var/text = ""

	boutput(world, "<FONT size = 2><B>The ship commanders were: </B></FONT><br>")
	// for(var/datum/mind/leader_mind in commanders)

	..() // Admin-assigned antagonists or whatever.


/datum/pod_wars_team
	var/name = "NanoTrasen Crew"
	var/comms_frequency = 0
	var/area/base_area = null		//base ship area
	var/datum/mind/commander = null
	var/list/members = list()
	var/team_num = 0

	var/points = 100
	var/list/mcguffins = list()		//Should have 4 AND ONLY 4
	var/datum/game_mode/pod_war/mode

	New(var/datum/game_mode/pod_war/mode, team)
		src.mode = mode
		src.team_num = team
		if (team_num == TEAM_NANOTRASEN)
			name = "NanoTrasen Crew"
			// base_area = /area/podmode/team1 //area south crew
		else if (team_num == TEAM_SYNDICATE)
			name = "Syndicate Crew"
			// base_area = /area/podmode/team2 //area north crew

		set_comms(mode)

	proc/change_points(var/amt)
		points += amt

		if (points <= 0)
			mode.check_finished()


	proc/set_comms(var/datum/game_mode/pod_war/mode)
		comms_frequency = rand(1360,1420)

		while(comms_frequency in mode.frequencies_used)
			comms_frequency = rand(1360,1420)

		mode.frequencies_used += comms_frequency


	proc/accept_players(var/list/players)
		members = players
		select_commander()

		for (var/datum/mind/M in players)
			equip_player(M.current)
			//commander gets a couple extra things...
			if (M == commander)
				equip_commander(M)
			M.current.antagonist_overlay_refresh(1,0)

	proc/select_commander()
		var/list/possible_commanders = get_possible_commanders()
		if (isnull(possible_commanders) || !possible_commanders.len)
			return 0

		commander = pick(possible_commanders)
		commander.special_role = "commander"
		return 1

//Really stolen from gang, But this basically just picks everyone who is ready and not hellbanned or jobbanned from Command or Captain
	proc/get_possible_commanders()
		var/list/candidates = list()
		for(var/datum/mind/mind in members)
			var/mob/new_player/M = mind.current
			if (!istype(M)) continue
			if (ishellbanned(M)) continue
			if(jobban_isbanned(M, "Captain")) continue //If you can't captain a Space Station, you probably can't command a starship either...
			if ((M.ready) && !candidates.Find(M.mind))
				candidates += M.mind

		if(candidates.len < 1)
			return null
		else
			return candidates

	proc/equip_commander(var/datum/mind/mind)
		var/mob/living/carbon/human/H = mind.current
		if (team_num == TEAM_NANOTRASEN)
			H.equip_if_possible(new /obj/item/clothing/head/centhat(H), H.slot_l_store)
			// H.equip_if_possible(new /obj/item/clothing/head/centhat(H), H.slot_r_store)
			H.mind.special_role = "NanoTrasen Commander"
		if (team_num == TEAM_SYNDICATE)
			H.equip_if_possible(new /obj/item/clothing/head/bighat/syndicate(H), H.slot_l_store)
			// H.equip_if_possible(new /obj/item/clothing/head/bighat/syndicate(H), H.slot_r_store)
			H.mind.special_role = "Syndicate Commander"


	proc/equip_player(var/mob/M)
		var/mob/living/carbon/human/H = M

		if (istype(M, /mob/new_player))
			var/mob/new_player/N = M
			N.mind.assigned_role = name
			H = N.create_character(new /datum/job/pod_pilot)

		if (!ishuman(H))
			boutput(H, "something went wrong. Horribly wrong.")
			return

		// SHOW_TIPS(H)

		H.mind.special_role = name

		var/obj/item/card/id/captains_spare/I = new /obj/item/card/id/captains_spare(H) // for whatever reason, this is neccessary
		I.registered = "[H.name]"
		I.icon = 'icons/obj/items/card.dmi'
		I.icon_state = "id_com"
		I.desc = "An ID card to help open doors, lock pods, and identify your body."

		var/obj/item/device/radio/headset/headset = new /obj/item/device/radio/headset(H)

		if (team_num == TEAM_NANOTRASEN)
			I.name = "NT Pilot"
			I.assignment = "NT Pilot"
			I.color = "#0000ff"
			H.equip_if_possible(new /obj/item/clothing/under/misc/turds(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/gloves/swat/NT(H), H.slot_gloves)
			H.equip_if_possible(new /obj/item/clothing/mask/breath(H), H.slot_wear_mask)
			H.equip_if_possible(new /obj/item/clothing/head/helmet/space/ntso(H), H.slot_head)
			H.equip_if_possible(new /obj/item/storage/backpack/NT(H), H.slot_back)
			H.equip_if_possible(headset, H.slot_ears)


		else if (team_num == TEAM_SYNDICATE)
			I.name = "Syndicate Pilot"
			I.assignment = "Syndicate Pilot"
			I.color = "#ff0000"
			H.equip_if_possible(new /obj/item/clothing/under/misc/syndicate(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/gloves/swat(H), H.slot_gloves)
			H.equip_if_possible(new /obj/item/clothing/mask/breath(H), H.slot_wear_mask)
			H.equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate/specialist(H), H.slot_head)
			H.equip_if_possible(new /obj/item/storage/backpack/syndie(H), H.slot_back)
			H.equip_if_possible(headset, H.slot_ears)


		if (headset)
			headset.set_secure_frequency("g",comms_frequency)
			headset.secure_classes["g"] = RADIOCL_SYNDICATE
			boutput(H, "Your headset has been tuned to your crew's frequency. Prefix a message with :g to communicate on this channel.")

		H.equip_if_possible(new /obj/item/clothing/shoes/swat(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/gun/energy/phaser_gun(H), H.slot_belt)

		H.equip_if_possible(I, H.slot_wear_id)
		H.set_clothing_icon_dirty()
		// H.set_loc(pick(pod_pilot_spawns[team_num]))
		boutput(H, "You're in the [name] faction! Mine materials, build pods, defend your space station, destroy the enemy space station!")


/obj/pod_carrier_critical_system
	name = "Critical System"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "def_radar"
	anchored = 1
	density = 1

	var/datum/pod_wars_team/team = null	//must set this in map editor or else it goes by area. 1 for NT, 2 for SYNDICATE
	var/health = 1000

	New()
		..()
		if (ticker.mode == /datum/game_mode/pod_war)
			var/datum/game_mode/pod_war/mode = ticker.mode
			if (get_area(src) == mode.team_NT.base_area)
				team = mode.team_NT
			else if (get_area(src) == mode.team_SY.base_area)
				team = mode.team_SY


	disposing()
		..()
		if (istype(team))
			team.change_points(-25)

		if (ticker.mode == /datum/game_mode/pod_war)
			var/datum/game_mode/pod_war/mode = ticker.mode
			mode.announce_critical_system_destruction(src)


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

	proc/take_damage(var/damage)
		if (damage > 0)
			src.health -= damage

		if (health <= 0)
			qdel(src)

//////////////special clone pod///////////////

/obj/machinery/clonepod/automatic
	name = "Cloning Pod Deluxe"
	meat_level = 1.#INF
	var/last_check = 0
	var/check_delay = 10 SECONDS
	var/datum/pod_wars_team/team

	process()
		if(!src.attempting)
			if (world.time - last_check >= check_delay)
				last_check = world.time
				INVOKE_ASYNC(src, /obj/machinery/clonepod/automatic.proc/growclone_a_ghost)
		return..()

	New()
		..()
		animate_rainbow_glow(src) // rgb shit cause it looks cool
		SubscribeToProcess()
		last_check = world.time

		if (ticker.mode == /datum/game_mode/pod_war)
			var/datum/game_mode/pod_war/mode = ticker.mode
			if (get_area(src) == mode.team_NT.base_area)
				team = mode.team_NT
			else if (get_area(src) == mode.team_SY.base_area)
				team = mode.team_SY

	disposing()
		..()
		UnsubscribeProcess()

	proc/growclone_a_ghost()
		var/list/to_search

		if (isnull(team))
			to_search = mobs

		//so we only clone the right crew members on the right ship
		else if (ticker.mode == /datum/game_mode/pod_war)
			var/datum/game_mode/pod_war/mode = ticker.mode
			if (team == mode.team_NT)
				to_search = mode.team_NT.members
			else if (team == mode.team_SY)
				to_search = mode.team_SY.members

		for(var/mob/dead/observer/ghost in to_search)
			var/datum/mind/ghost_mind = ghost.mind
			if(ghost.client && !ghost_mind.dnr)
				growclone(ghost, ghost.real_name, ghost_mind)
				break
