#define TEAM_NANOTRASEN 1
#define TEAM_SYNDICATE 2
/datum/game_mode/pod_wars
	name = "pod wars"
	config_tag = "pod_wars"
	votable = 1
	probability = 0 // Overridden by the server config. If you don't have access to that repo, keep it 0.
	crew_shortage_enabled = 1

	shuttle_available = 0 // 0: Won't dock. | 1: Normal. | 2: Won't dock if called too early.
	list/latejoin_antag_roles = list() // Unrecognized roles default to traitor in mob/new_player/proc/makebad().
	do_antag_random_spawns = 0
	var/list/frequencies_used = list()


	var/datum/pod_wars_team/team_NT
	var/datum/pod_wars_team/team_SY

	var/obj/screen/score_board/board

	proc/update_status()



/datum/game_mode/pod_wars/announce()
	boutput(world, "<B>The current game mode is - Pod Wars!</B>")
	boutput(world, "<B>Two starships of similar technology and crew compliment warped into the same asteroid field!</B>")
	boutput(world, "<B>Mine materials, build pods, kill enemies, destroy the enemy mothership!</B>")

//setup teams and commanders
/datum/game_mode/pod_wars/pre_setup()
	board = new()
	if (!setup_teams())
		return 0

	handle_point_change(team_NT)	//HAX. am
	handle_point_change(team_SY)	//HAX. am

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
			if (prob(100))
				team_NT.accept_players(readied_minds)
			else
				team_SY.accept_players(readied_minds)

		else
			var/half = round(length/2)
			team_NT.accept_players(readied_minds.Copy(1, half))
			team_SY.accept_players(readied_minds.Copy(half+1, length))

	return 1



/datum/game_mode/pod_wars/post_setup()
	return 1

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

	message_admins("[team]||[team_NT]||[team_SY]--[fraction]")
	// animate(bar_to_change, transform = M1, pixel_x = offset, time = 10)
	if (team == team_NT)
		animate(board.bar_NT, transform = M1, pixel_x = offset, time = 10)
	else
		animate(board.bar_SY, transform = M1, pixel_x = offset, time = 10)

	if (team.points <= 0)
		check_finished()

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


/datum/game_mode/pod_wars/proc/announce_critical_system_destruction(var/team_name, var/obj/pod_base_critical_system/CS)

	world << ("<h2><span class='alert'>[team_name]'s [CS] has been destroyed!!</span></h2>")




/datum/game_mode/pod_wars/check_finished()


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
	var/name = "NanoTrasen Crew"
	var/comms_frequency = 0
	var/area/base_area = null		//base ship area
	var/datum/mind/commander = null
	var/list/members = list()
	var/team_num = 0

	var/points = 50
	var/max_points = 100
	var/list/mcguffins = list()		//Should have 4 AND ONLY 4
	var/datum/game_mode/pod_wars/mode

	New(var/datum/game_mode/pod_wars/mode, team)
		..()
		src.mode = mode
		src.team_num = team
		if (team_num == TEAM_NANOTRASEN)
			name = "NanoTrasen Crew"
			base_area = /area/podmode/team1 //area north, NT crew
		else if (team_num == TEAM_SYNDICATE)
			name = "Syndicate Crew"
			base_area = /area/podmode/team2 //area south, Syndicate crew

		set_comms(mode)

	proc/change_points(var/amt)
		points += amt
		mode.handle_point_change(src)


	proc/set_comms(var/datum/game_mode/pod_wars/mode)
		comms_frequency = rand(1360,1420)

		while(comms_frequency in mode.frequencies_used)
			comms_frequency = rand(1360,1420)

		mode.frequencies_used += comms_frequency


	proc/accept_players(var/list/players)
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

	proc/equip_player(var/mob/M)
		var/mob/living/carbon/human/H = M

		if (istype(M, /mob/new_player))
			var/mob/new_player/N = M
			if (team_num == TEAM_NANOTRASEN)
				N.mind.assigned_role = "NanoTrasen Pod Pilot"
			else if (team_num == TEAM_SYNDICATE)
				N.mind.assigned_role = "Syndicate Pod Pilot"
			// H = N.create_character(new /datum/job/pod_wars)	//should use this, but I wrote the stuff here first and lazy...

		if (!ishuman(H))
			boutput(H, "something went wrong. Horribly wrong.")
			return

		// SHOW_TIPS(H)

		H.mind.special_role = name

		var/obj/item/device/radio/headset/headset = new /obj/item/device/radio/headset(H)

		if (team_num == TEAM_NANOTRASEN)
			var/obj/item/card/id/pod_wars/nanotrasen/I = new/obj/item/card/id/pod_wars/nanotrasen(H)
			//commanders get a couple extra things...
			if (H.mind == commander)
				H.mind.special_role = "NanoTrasen Commander"
				I.name = "NT Commander"
				I.assignment = "NT Commander"
				H.equip_if_possible(new /obj/item/clothing/head/NTberet/commander(H), H.slot_head)
				H.equip_if_possible(new /obj/item/clothing/suit/space/nanotrasen/pilot/commander(H), H.slot_wear_suit)
			else
				H.equip_if_possible(new /obj/item/clothing/head/helmet/space/ntso(H), H.slot_head)
				H.equip_if_possible(new /obj/item/clothing/suit/space/nanotrasen/pilot(H), H.slot_wear_suit)

			H.equip_if_possible(I, H.slot_wear_id)

			H.equip_if_possible(headset, H.slot_ears)
			H.equip_if_possible(new /obj/item/storage/backpack/NT(H), H.slot_back)
			H.equip_if_possible(new /obj/item/clothing/under/misc/turds(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/gloves/swat/NT(H), H.slot_gloves)
			H.equip_if_possible(new /obj/item/clothing/mask/breath(H), H.slot_wear_mask)
			H.equip_if_possible(new /obj/item/gun/energy/blaster_pod_wars/nanotrasen(H), H.slot_belt)



		else if (team_num == TEAM_SYNDICATE)
			var/obj/item/card/id/pod_wars/syndicate/I = new/obj/item/card/id/pod_wars/syndicate(H)
			if (H.mind == commander)
				H.mind.special_role = "Syndicate Commander"
				I.name = "Syndicate Commander"
				I.assignment = "Syndicate Commander"
				if (prob(10))
					H.equip_if_possible(new /obj/item/clothing/head/bighat/syndicate(H), H.slot_l_store)
				else
					H.equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate/commissar_cap(H), H.slot_l_store)
				H.equip_if_possible(new /obj/item/clothing/suit/space/syndicate/commissar_greatcoat(H), H.slot_wear_suit)

			else
				H.equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate/specialist(H), H.slot_head)
				H.equip_if_possible(new /obj/item/clothing/suit/space/syndicate(H), H.slot_wear_suit)

			H.equip_if_possible(I, H.slot_wear_id)
			H.equip_if_possible(headset, H.slot_ears)
			H.equip_if_possible(new /obj/item/storage/backpack/syndie(H), H.slot_back)
			H.equip_if_possible(new /obj/item/clothing/under/misc/syndicate(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/gloves/swat(H), H.slot_gloves)
			H.equip_if_possible(new /obj/item/clothing/mask/breath(H), H.slot_wear_mask)
			H.equip_if_possible(new /obj/item/gun/energy/blaster_pod_wars/syndicate(H), H.slot_belt)


		if (headset)
			headset.set_secure_frequency("g",src.comms_frequency)
			headset.secure_classes["g"] = RADIOCL_SYNDICATE
			boutput(H, "Your headset has been tuned to your crew's frequency. Prefix a message with :g to communicate on this channel.")

		H.equip_if_possible(new /obj/item/clothing/shoes/swat(H), H.slot_shoes)

		H.set_clothing_icon_dirty()
		// H.set_loc(pick(pod_pilot_spawns[team_num]))
		boutput(H, "You're in the [name] faction!")
		H.client.screen += mode.board


/obj/pod_base_critical_system
	name = "Critical System"
	icon = 'icons/obj/64x64.dmi'
	icon_state = "critical_system"
	anchored = 1
	density = 1
	bound_width = 64
	bound_height = 64

	var/health = 1000
	var/team_num		//used for getting the team datum, this is set to 1 or 2 in the map editor. 1 = NT, 2 = Syndicate

	New()
		..()

	disposing()
		..()

		if (ticker.mode == /datum/game_mode/pod_wars)
			//get the team datum from its team number right when we allocate points.
			var/datum/game_mode/pod_wars/mode = ticker.mode
			var/name
			if (team_num == TEAM_NANOTRASEN)
				name = "NanoTrasen"
				mode?.team_NT.change_points(-25)
			else if (team_num == TEAM_SYNDICATE)
				name = "The Syndicate"
				mode?.team_SY.change_points(-25)

			mode.announce_critical_system_destruction(name, src)


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


	disposing()
		..()
		UnsubscribeProcess()

	proc/growclone_a_ghost()
		var/list/to_search
		if (istype(team))
			to_search = team.members
		else
			return

		for(var/mob/dead/observer/ghost in to_search)
			var/datum/mind/ghost_mind = ghost.mind
			if(ghost.client && !ghost_mind.dnr)
				var/success = growclone(ghost, ghost.real_name, ghost_mind)
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
	burst_size = 2 // number of shots to fire. Keep in mind the bullet's shot_count
	fire_rate = 2 // rate of fire in shots per second
	angle_arc_size = 120
	quick_deploy_fuel = 2
	var/deployer_path = /obj/deployable_turret/pod_wars

	New(var/direction)
		..(direction=direction)


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

			if (src.target_valid(C))
				src.target_list += C
				var/distance = get_dist(C.loc,src.loc)
				src.target_list[C] = distance

			else
				continue

		for (var/obj/machinery/vehicle/V in by_cat[TR_CAT_PODS_AND_CRUISERS])
			if (pod_target_valid(V))
				var/distance = get_dist(V.loc,src.loc)
				target_list[V] = distance

		if (src.target_list.len>0)
			var/min_dist = 99999

			for (var/atom/T in src.target_list)
				if (src.target_list[T] < min_dist)
					src.target = T
					min_dist = src.target_list[T]

			src.icon_state = "[src.icon_tag]_active"

			playsound(src.loc, "sound/vox/woofsound.ogg", 40, 1)

		return src.target

	proc/pod_target_valid(var/obj/machinery/vehicle/V )
		var/distance = get_dist(V.loc,src.loc)
		if(distance > src.range)
			return 0

		if (ismob(V.pilot))
			return is_friend(V.pilot)




/obj/item/turret_deployer/pod_wars/nt
	icon_tag = "nt"
	turret_path = /obj/deployable_turret/pod_wars/nt

/obj/deployable_turret/pod_wars/nt
	deployer_path = /obj/deployable_turret/pod_wars/nt
	projectile_type = /datum/projectile/laser/blaster/pod_pilot/blue_NT
	current_projectile = new/datum/projectile/laser/blaster/pod_pilot/blue_NT
	icon_tag = "nt"

	is_friend(var/mob/living/C)
		var/obj/item/card/id/I = C.get_id()
		if(!istype(I))
			return 0
		switch(I.assignment)
			if("NT Commander")
				return 1
			if("NT Pilot")
				return 1
			else
				return 0

	ABSTRACT_TYPE(/obj/deployable_turret/pod_wars/nt/activated)
	activated
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
		var/obj/item/card/id/I = C.get_id()
		if(!istype(I))
			return 0
		switch(I.assignment)
			if("Syndicate Commander")
				return 1
			if("Syndicate Pilot")
				return 1
			else
				return 0

	ABSTRACT_TYPE(/obj/deployable_turret/pod_wars/sy/activated)
	activated
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
	var/team = 0 //TEAM_SYNDICATE
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
					team = get_team(I)
					ship.locked = 0
					return

			if (istype(I))
				if (I == assigned_id || get_team(I) == team)
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
	health = 140
	maxhealth = 140
	anchored = 0
	var/weapon_type = /obj/item/shipcomponent/mainweapon/phaser/short

	New()
		..()
		/obj/item/shipcomponent/mainweapon/phaser/short

		src.m_w_system = new weapon_type( src )
		src.m_w_system.ship = src

		src.sec_system = new /obj/item/shipcomponent/secondary_system/orescoop( src )
		src.sec_system.ship = src
		src.components += src.sec_system

		myhud.update_systems()
		myhud.update_states()
		return

	nanotrasen
		name = "NT Mining Dingy"
		icon_state = "putt_pre"

		mining
			name = "NT Mining Dingy"
			weapon_type = /obj/item/shipcomponent/mainweapon/bad_mining

	syndicate
		name = "Syndicate Mining Dingy"
		icon_state = "syndiputt"

		mining
			name = "Syndicate Mining Dingy"
			weapon_type = /obj/item/shipcomponent/mainweapon/bad_mining
