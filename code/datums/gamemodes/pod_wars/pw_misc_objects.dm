/obj/pod_base_critical_system
	name = "critical system"
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "critical_system"
	anchored = ANCHORED
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
		user.lastattacked = get_weakref(src)

		//Healing with welding tool
		if (health <= health_max && isweldingtool(W))
			if(!W:try_weld(user, 1))
				return
			take_damage(-30)
			src.visible_message(SPAN_ALERT("[user] has fixed some of the damage on [src]!"))
			if(health >= health_max)
				health = health_max
				src.visible_message(SPAN_ALERT("[src] is fully repaired!"))
			return

		//normal damage stuff
		take_damage(W.force, user)
		src.add_fingerprint(user)

		..()

	get_desc()
		. = "<br>[SPAN_NOTICE("It looks like it has [health] HP left out of [health_max] HP. You can just tell. What is \"HP\" though? ")]"

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
			SPAWN(2 MINUTES)
				suppress_damage_message = 0


		if (health <= 0)
			qdel(src)

		if (!user)
			return	//don't log if damage isn't done by a user (like it's critters are turrets)

		//Friendly fire check
		if (get_pod_wars_team_num(user) == team_num)
			message_admins("[user] just committed friendly fire against [his_or_her(user)] team's [src]!")
			logTheThing(LOG_COMBAT, user, "\[POD WARS\][user] attacks [his_or_her(user)] own team's critical system [src].")

			if (istype(ticker.mode, /datum/game_mode/pod_wars))
				var/datum/game_mode/pod_wars/mode = ticker.mode
				mode.stats_manager?.inc_friendly_fire(user)

//////////////special clone pod///////////////

/obj/machinery/clonepod/pod_wars
	name = "cloning pod deluxe"
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
				INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/clonepod/pod_wars, growclone_a_ghost))
		return..()

	New()
		..()
		animate_rainbow_glow(src) // rgb shit cause it looks cool
		SubscribeToProcess()
		last_check = world.time

	ex_act(severity)
		return

	powered()
		return TRUE

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
			if((istype(mind.current, /mob/dead/observer) || isdead(mind.current)) && mind.current.client && !mind.get_player()?.dnr)
				//prune puritan trait
				mind.current?.traitHolder.removeTrait("puritan")
				var/success = growclone(mind.current, mind.current.real_name, mind, mind.current?.bioHolder, traits=mind.current?.traitHolder.copy())
				if (success && team)
					SPAWN(1)
						team.equip_player(src.occupant, FALSE)
				break

////////////////////////////////////////////////

/obj/forcefield/energyshield/perma/pod_wars
	name = "permanent military-grade forcefield"
	desc = "A permanent force field that prevents non-authorized entities from passing through it."
	var/team_num = 0		//1 = NT, 2 = SY
	gas_impermeable = TRUE

	Cross(atom/A)
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

ABSTRACT_TYPE(/obj/item/turret_deployer/pod_wars)
/obj/item/turret_deployer/pod_wars
	name = "turret deployer"
	desc = "A turret deployment thingy. Use it in your hand to deploy."
	icon_state = "st_deployer"
	w_class = W_CLASS_BULKY
	health = 125
	quick_deploy_fuel = 2
	associated_turret = /obj/deployable_turret/pod_wars

	spawn_turret(var/direct)
		var/obj/deployable_turret/pod_wars/turret = ..()
		turret.reconstruction_time = 0		//can't reconstruct itself
		return turret

ABSTRACT_TYPE(/obj/deployable_turret/pod_wars)
/obj/deployable_turret/pod_wars
	name = "ship defense turret"
	desc = "A ship defense turret."
	health = 100
	max_health = 100
	wait_time = 20 //wait if it can't find a target
	range = 8 // tiles
	burst_size = 3 // number of shots to fire. Keep in mind the bullet's shot_count
	fire_rate = 3 // rate of fire in shots per second
	angle_arc_size = 180
	quick_deploy_fuel = 2
	associated_deployer = /obj/item/turret_deployer/pod_wars
	can_toggle_activation = FALSE
	var/destroyed = 0
	var/reconstruction_time = 5 MINUTES

	//Might be nice to allow players to "repair"  Dead turrets to speed up their timer, but not now. too lazy - kyle
	//just "deactivates"
	die()
		if (!destroyed)
			playsound(get_turf(src), 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 1)
			destroyed = 1
			new /obj/decal/cleanable/robot_debris(src.loc)
			src.alpha = 30
			src.set_opacity(0)
			if (reconstruction_time)
				sleep(reconstruction_time)
				src.set_opacity(1)
				src.alpha = 255
				health = initial(health)
				destroyed = 0
				active = 1
			else
				..()

	//VERY POSSIBLY UNNEEDED, -KYLE
	// proc/pod_target_valid(var/obj/machinery/vehicle/V )
	// 	var/distance = GET_DIST(V.loc,src.loc)
	// 	if(distance > src.range)
	// 		return 0

	// 	if (ismob(V.pilot))
	// 		return is_friend(V.pilot)
	// 	else
	// 		return 0

/obj/item/turret_deployer/pod_wars/nt
	icon_tag = "nt"
	associated_turret = /obj/deployable_turret/pod_wars/nt

/obj/deployable_turret/pod_wars/nt
	associated_deployer = /obj/item/turret_deployer/pod_wars/nt
	projectile_type = /datum/projectile/laser/blaster/pod_pilot/blue_NT/turret
	icon_tag = "nt"

	is_friend(var/mob/living/C)
		if (!C.ckey || !C.mind)
			return 1
		if (C.mind?.special_role != "Syndicate")
			return 1
		else
			return 0

/obj/deployable_turret/pod_wars/nt/activated
	anchored=1
	active=1
	deconstructable = FALSE

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
	associated_turret = /obj/deployable_turret/pod_wars/sy

/obj/deployable_turret/pod_wars/sy
	associated_deployer = /obj/item/turret_deployer/pod_wars/sy
	projectile_type = /datum/projectile/laser/blaster/pod_pilot/red_SY/turret
	icon_tag = "st"

	is_friend(var/mob/living/C)
		if (!C.ckey || !C.mind)
			return 1
		if (C.mind.special_role != "NanoTrasen")
			return 1
		else
			return 0

/obj/deployable_turret/pod_wars/sy/activated
	anchored=1
	active=1
	deconstructable = FALSE
	north
		dir=NORTH
	south
		dir=SOUTH
	east
		dir=EAST
	west
		dir=WEST

/obj/item/shipcomponent/secondary_system/lock/pw_id
	name = "\improper ID card hatch locking unit"
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

			if(!istype(I, /obj/item/card/id/pod_wars))
				boutput(user, SPAN_ALERT("[ship]'s locking mechanism is incompatible with your ID!"))
				return
			var/obj/item/card/id/pod_wars/PW_ID = I
			if (isnull(assigned_id))
				if (istype(I))
					boutput(user, SPAN_NOTICE("[ship]'s locking mechinism recognizes [I] as its key!"))
					playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
					assigned_id = I
					team_num = PW_ID.team
					ship.locked = 0
					return

			if (istype(I))
				if (I == assigned_id || PW_ID.team == team_num)
					ship.locked = !ship.locked
					boutput(user, SPAN_ALERT("[ship] is now [ship.locked ? "locked" : "unlocked"]!"))

////////////////////PDAs and PDA Accessories/////////////////////
/obj/item/device/pda2/pod_wars
	setup_default_cartridge = /obj/item/disk/data/cartridge/pod_pilot //hos cart gives access to manifest compared to regular sec cart, useful for NTSO
	mailgroups = list()
	bombproof = 1
	var/team_num 			// 1 TEAM_NANOTRASEN, 2 TEAM_SYNDICATE

#if defined(MAP_OVERRIDE_POD_WARS)
	//You can only pick this up if you're on the correct team, otherwise it explodes.
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == src.team_num)
			..()
		else
			var/flavor = pick("doesn't like you", "can tell you don't deserve it", "saw into your very soul and found you wanting", "hates you", "thinks you stink", "thinks you two should start seeing other people", "doesn't trust you", "finds your lack of faith disturbing", "is just not that into you", "gently weeps")
			//stolen from Captain's Explosive Spare ID down below...
			boutput(user, SPAN_ALERT("The ID card [flavor] and <b>explodes!</b>"))
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
#endif

	nanotrasen
		icon_state = "pda-nt"
		setup_default_module = /obj/item/device/pda_module/flashlight/nt_blue
		team_num = TEAM_NANOTRASEN

	syndicate
		icon_state = "pda-syn"
		desc = "A cheap knockoff looking portable microcomputer claiming to be made by ElecTek LTD. It has a slot for an ID card, and a hole to put a pen into."
		locked_bg_color = TRUE
		bg_color = "#A33131"
		r_tone = /datum/ringtone/basic/ring10
		screen_x = 2
		window_title = "Personnel Data Actuator"
		setup_default_module = /obj/item/device/pda_module/flashlight/sy_red
		team_num = TEAM_SYNDICATE

		New()
			..()
			var/datum/computer/file/text/pda2manual/old_manual = locate() in src.hd.root.contents
			src.hd.root.remove_file(old_manual)
			var/datum/computer/file/pda_program/emergency_alert/crisis = locate() in src.hd.root.contents
			src.hd.root.remove_file(crisis)
			src.hd.root.add_file(new /datum/computer/file/text/pda2manual/knockoff)

/obj/item/device/pda_module/flashlight/nt_blue
	name = "\improper NanoTrasen blue flashlight module"
	desc = "Love (or work for) NanoTrasen? This'll be your favorite flashlight!"
	lumlevel = 0.8
	light_r = 61
	light_g = 156
	light_b = 255


/obj/item/device/pda_module/flashlight/sy_red
	name = "\improper Syndicate red flashlight module"
	desc = "Hate (or used to work for) NanoTrasen? This'll be your favorite flashlight!"
	lumlevel = 0.8
	//#ff4043
	light_r = 255
	light_g = 64
	light_b = 67

/obj/item/disk/data/cartridge/pod_pilot
	name = "standard utility cartridge"
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

///////////Headsets////////////////
//OK look, I made these objects, but I probably didn't need to. Setting the frequencies is done in the job equip.
//Mainly I did it to give them the icon_override vars. Don't spawn these unless you want to set their secure frequencies yourself, because that's what you'd have to do. -Kyle
/obj/item/device/radio/headset/pod_wars
	protected_radio = 1
	var/team = 0

	//You can only pick this up if you're on the correct team, otherwise it explodes.
	//exactly the same as /obj/item/card/id/pod_wars. Copy paste bad, but these two things I don't want people stealing, would be real lame... Might get rid of in the future if this structure isn't required.
#if defined(MAP_OVERRIDE_POD_WARS)
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team)
			..()
		else
			boutput(user, SPAN_ALERT("The headset <b>explodes</b> as you reach out to grab it!"))
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
#endif

/obj/item/device/radio/headset/pod_wars/nanotrasen
	name = "radio headset"
	desc = "A radio headset that is also capable of communicating over, this one is tuned into a NanoTrasen frequency"
	icon_state = "headset"
	secure_frequencies = list("g" = R_FREQ_SYNDICATE)
	secure_classes = list(RADIOCL_COMMAND)
	secure_colors = list("#0099cc")
	icon_override = "nt"
	icon_tooltip = "NanoTrasen"
	team = TEAM_NANOTRASEN

	commander
		icon_override = "ntboss"	//get better thingy // better thingy gotten
		icon_tooltip = "NanoTrasen Commander"

/obj/item/device/radio/headset/pod_wars/nanotrasen/comtac
	name = "military headset"
	icon_state = "radio" // blue enough
	desc = "A two-way radio headset designed to protect the wearer from dangerous levels of noise during gunfights."

	setupProperties()
		..()
		setProperty("disorient_resist_ear", 100)

/obj/item/device/radio/headset/pod_wars/syndicate
	name = "radio headset"
	desc = "A radio headset that is also capable of communicating over, this one is tuned into a Syndicate frequency"
	icon_state = "headset"
	secure_frequencies = list("g" = R_FREQ_SYNDICATE)
	secure_classes = list(RADIOCL_SYNDICATE)
	secure_colors = list("#ff69b4")
	protected_radio = 1
	icon_override = "syndie"
	icon_tooltip = "Syndicate"
	team = TEAM_SYNDICATE

	commander
		icon_override = "syndieboss"
		icon_tooltip = "Syndicate Commander"

/obj/item/device/radio/headset/pod_wars/syndicate/comtac
	name = "military headset"
	icon_state = "comtac"
	desc = "A two-way radio headset designed to protect the wearer from dangerous levels of noise during gunfights."

	setupProperties()
		..()
		setProperty("disorient_resist_ear", 100)


/////////shit//////////////

/obj/control_point_computer
	name = "computer"	//name it based on area.
	icon = 'icons/obj/control_point_computer.dmi'
	icon_state = "control_point_computer"
	density = 1
	anchored = ANCHORED

	var/image/screen
	var/image/screen_light
	var/image/name_overlay

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

		src.update_screen("screen")

		if (src.dir == NORTH || src.dir == SOUTH)
			src.bound_width = 64
			src.bound_height = 32
		else if (src.dir == EAST || src.dir == WEST)
			src.bound_width = 32
			src.bound_height = 64

	proc/update_screen(var/icon_state)
		src.screen = image('icons/obj/control_point_computer.dmi', icon_state)
		src.UpdateOverlays(src.screen, "screen")

		src.screen_light = image('icons/obj/control_point_computer.dmi', icon_state)
		src.screen_light.plane = PLANE_LIGHTING
		src.screen_light.blend_mode = BLEND_ADD
		src.screen_light.layer = LIGHTING_LAYER_BASE
		src.screen_light.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
		src.UpdateOverlays(src.screen_light, "screen_light")

	proc/update_name_overlay(var/icon_state)
		src.name_overlay = image('icons/obj/control_point_computer.dmi', icon_state)
		src.UpdateOverlays(src.name_overlay, "name_overlay")

	ex_act()
		return

	meteorhit(var/obj/O as obj)
		return

	//called from the action bar completion in src.Attackhand()
	proc/capture(var/mob/user)
		var/team_num = get_pod_wars_team_num(user)
		owner_team = team_num
		update_light_color()

		ctrl_pt.capture(user, team_num)
		switch(get_pod_wars_team_num(user))
			if (TEAM_NANOTRASEN)
				message_ghosts("<b>[user]</b> successfully captured [src] for Nanotrasen! [log_loc(src, ghostjump=TRUE)].")
			if (TEAM_SYNDICATE)
				message_ghosts("<b>[user]</b> successfully captured [src] for the Syndicate! [log_loc(src, ghostjump=TRUE)].")

	attack_hand(mob/user)
		if (!can_be_captured)
			var/cur_time
			var/datum/game_mode/pod_wars/mode = ticker.mode
			if (istype(mode))
				cur_time = round((mode.activate_control_points_time-ticker.round_elapsed_ticks) / (1 MINUTES), 1)	//converts to minutes
			else
				cur_time = round( 15 MINUTES / 1 MINUTES, 1)


			boutput(user, SPAN_NOTICE("This computer seems to be frozen on a space-weather tracking screen. It looks like a large ion storm will be passing this system in about <b class='alert'>[(cur_time)] minutes mission time</b>.<br>You can't input any commands to run the control protocols for this satelite..."))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE, flags = SOUND_IGNORE_SPACE)
			return 0
		if (owner_team != get_pod_wars_team_num(user))
			var/duration = is_commander(user) ? 10 SECONDS : 20 SECONDS
			playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 150, 1, flags = SOUND_IGNORE_SPACE)	//loud

			if(!ON_COOLDOWN(src, "ghostalert", 10 SECONDS))
				message_ghosts("<b>[user]</b> is trying to capture <b>[src]</b>! [log_loc(src, ghostjump=TRUE)].")
			SETUP_GENERIC_ACTIONBAR(user, src, duration, /obj/control_point_computer/proc/capture, list(user),\
			 null, null, "[user] successfully enters [his_or_her(user)] command code into \the [src]!", null)
		else
			boutput(user, SPAN_ALERT("You can't think of anything else to do on this console..."))

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
			src.update_screen("nanotrasen")
		else if (owner_team == TEAM_SYNDICATE)
			light_r = 1
			light_g = 0
			light_b = 0
			src.update_screen("syndicate")
		else
			light_r = 1
			light_g = 1
			light_b = 1
			src.update_screen("screen")

		light.set_color(light_r, light_g, light_b)

/obj/warp_beacon/pod_wars
	var/control_point 		//currently only use values FORTUNA, RELIANT, UVB67 		//set in map file
	var/current_owner		//which team is the owner right now. Acceptable values: null, TEAM_NANOTRASEN = 1, TEAM_SYNDICATE = 1

	ex_act()
		return
	meteorhit(var/obj/O as obj)
		return
	attackby(obj/item/W, mob/user)
		return

	//These are basically the same as "normal" pod_wars beacons, but they won't have a capture point so they should never get an owner team
	//so nobody will be able to warp to them, they can only navigate towards them with pod sensors.
	spacejunk
		name = "spacejunk warp_beacon"
		invisibility = INVIS_ALWAYS
		alpha = 100			//just to be clear


/////////////Barricades////////////

/obj/barricade
	name = "barricade"
	desc = "A barricade. It looks like you can shoot over it and beat it down, but not walk over it. Devious."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barricade"
	density = 1
	anchored = ANCHORED
	flags = NOSPLASH
	event_handler_flags = USE_FLUID_ENTER
	layer = OBJ_LAYER-0.1
	stops_space_move = TRUE
	var/icon_damaged = "barricade-damaged"

	var/health = 100
	var/health_max = 100

	get_desc()
		var/string = "pristine"
		if (health == health_max)
			string = "pristine"
		else if (health >= (health_max/2))
			string = "a bit scuffed"
		else
			string = "almost destroyed"

		. = "<br>[SPAN_NOTICE("It looks [string].")]"

	ex_act(severity)

		return

	Cross(atom/movable/mover)
		if (!src.density || (mover.flags & TABLEPASS || istype(mover, /obj/newmeteor)) )
			return 1
		else
			return 0
	Bumped(atom/AM)
		if (istype(AM, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/V = AM
			V.health -= round(src.health/4)
			V.checkhealth()
			playsound(get_turf(src), 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			qdel(src)
		..()

	attackby(var/obj/item/W, var/mob/user)
		attack_particle(user,src)
		take_damage(W.force)
		playsound(get_turf(src), 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 20, 1)
		user.lastattacked = get_weakref(src)
		..()

	attack_hand(mob/user)
		switch (user.a_intent)
			if (INTENT_HELP)
				visible_message(SPAN_NOTICE("[user] pats [src] [pick("earnestly", "merrily", "happily","enthusiastically")] on top."))
			if (INTENT_DISARM)
				visible_message(SPAN_ALERT("[user] tries to shove [src], but it was ineffective!"))
			if (INTENT_GRAB)
				visible_message(SPAN_ALERT("[user] tries to wrassle with [src], but it gives no ground!"))
			if (INTENT_HARM)
				if (ishuman(user))
					if (user.is_hulk())
						take_damage(20)
					else
						take_damage(5)
					playsound(get_turf(src), 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 25, 1)
					attack_particle(user,src)


		user.lastattacked = get_weakref(src)
		..()

	proc/take_damage(var/damage)
		src.health -= damage

		//This works correctly because at the time of writing, these barricades cannot be repaired.
		if (health < health_max/2)
			if (icon_damaged)
				icon_state = icon_damaged

		if (health <= 0)
			qdel(src)

/obj/barricade/barbed
	name = "barbed barricade"
	desc = "A barbed barricade. It looks like you can shoot over it but making contact with it might be tricky."
	var/cooldown_time = 3 SECOND
	var/overlay_state = "barricade_sharp"

	New()
		. = ..()
		if(overlay_state)
			var/overlay = image(src.icon, overlay_state)
			UpdateOverlays(overlay, "barb")

	proc/pokey(mob/target, poke_chance=33)
		if(prob(poke_chance))
			if(ON_COOLDOWN(target, "BARB_\ref[src]", src.cooldown_time)) return
			target.visible_message("[target] gets caught up in [src]", "You get caught up in [src] and notice it has drawn blood.")
			take_bleeding_damage(target, null, rand(3,7), DAMAGE_STAB)
			return TRUE

	Bumped(atom/AM)
		. = ..()
		if(ismob(AM))
			var/mob/M = AM
			if(M.m_intent != "walk")
				pokey(M, 98)
			else
				pokey(M, 30)

	attackby(var/obj/item/W, var/mob/user)
		..()
		pokey(user, 15)

	attack_hand(mob/user)
		..()
		if (user.a_intent != INTENT_HELP)
			pokey(user, 88)
		else
			pokey(user, 33)

/obj/barricade/barbed/wire
	name = "barbed wire"
	desc = "A coiled length of barbed wire has been setup as a barricade."
	icon_state = "bwire"
	health = 50
	health_max = 50
	overlay_state = null
	density = 0
	icon_damaged = null

	pokey(mob/target, poke_chance=33)
		. = ..()
		target.changeStatus("slowed", 1 SECONDS)
		if(.)
			target.changeStatus("slowed", 4 SECONDS)
			target.TakeDamageAccountArmor("All", rand(1,2), 0, 0, DAMAGE_CUT)

	Crossed(atom/movable/mover)
		. = ..()
		// This change prevents ghosts from being affected by barbed wire
		if (HAS_ATOM_PROPERTY(mover, PROP_ATOM_FLOATING))
			return
		if(ismob(mover))
			var/mob/M = mover
			if(M.m_intent != "walk")
				pokey(M, 98)
			else
				pokey(M, 30)

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
		SETUP_GENERIC_ACTIONBAR(user, src, build_duration, PROC_REF(deploy), list(user, get_turf(user)),\
		 src.icon, src.icon_state, "[user] deploys \the [src]", null)

	//mostly stolen from furniture_parts/proc/construct
	proc/deploy(mob/user as mob, turf/T as turf)
		var/obj/newThing = null
		if (!T)
			T = user ? get_turf(user) : get_turf(src)
			if (!T) // buh??
				return
		if (istype(T, /turf/space))
			boutput(user, SPAN_ALERT("Can't build a barricade in space!"))
			return
		if (ispath(src.object_type))
			if (locate(src.object_type) in T.contents)
				boutput(user, SPAN_ALERT("There is already a barricade here! You can't think of a way that another one could possibly fit!"))
				return
			newThing = new src.object_type(T)
		else
			logTheThing(LOG_DIARY, user, "tries to deploy an object of type ([src.type]) from [src] but its object_type is null and it is being deleted.", "station")
			user.u_equip(src)
			qdel(src)
			return
		if (newThing)
			if (src.material)
				newThing.setMaterial(src.material)
			if (user)
				newThing.add_fingerprint(user)
				logTheThing(LOG_STATION, user, "builds \a [newThing] (<b>Material:</b> [newThing.material && newThing.material.getID() ? "[newThing.material.getID()]" : "*UNKNOWN*"]) at [log_loc(T)].")
		change_stack_amount(-1)
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
		playsound(loc, 'sound/effects/mag_warp.ogg', 100, TRUE, flags = SOUND_IGNORE_SPACE)
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
		SPAWN(1 SECONDS)
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
		ENSURE_TYPE(mode)
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

////////////// special pod wars cargo pads + mineral accumulators ///////////////

/obj/submachine/cargopad/pod_wars/syndicate
	name = "\improper Lodbrok mining pad"
	group = "syndicate"

/obj/submachine/cargopad/pod_wars/nanotrasen
	name = "\improper NSV Pytheas mining pad"
	group = "nanotrasen"

/obj/machinery/oreaccumulator/pod_wars/syndicate
	name = "\improper Syndicate mineral accumulator"
	group = "syndicate"

/obj/machinery/oreaccumulator/pod_wars/nanotrasen
	name = "\improper NanoTrasen mineral accumulator"
	group = "nanotrasen"


/obj/item/storage/belt/medical/podwars
	spawn_contents = list(/obj/item/reagent_containers/mender/brute,
	/obj/item/reagent_containers/mender/burn,
	/obj/item/reagent_containers/hypospray/emagged, // maybe fine. it'll be fine. i'm sure it's fine.
	/obj/item/device/analyzer/healthanalyzer/upgraded,
	/obj/item/robodefibrillator,
	/obj/item/clothing/glasses/healthgoggles/upgraded,
	/obj/item/suture )


/obj/reagent_dispensers/fueltank/pod_wars
	capacity = 10000
	bullet_act()
		return
	ex_act()
		return
	electric_expose()
		return
	meteorhit()
		return
	temperature_expose()
		return
	blob_act()
		return

	anchored
		anchored = ANCHORED_ALWAYS

/obj/machinery/portable_atmospherics/canister/toxins/pod_wars
	volume = 10000 // what could go wrong
	bullet_act()
		return
	ex_act()
		return
	electric_expose()
		return
	meteorhit()
		return
	temperature_expose()
		return
	blob_act()
		return

	anchored
		anchored = ANCHORED_ALWAYS

/obj/machinery/portable_atmospherics/canister/oxygen/pod_wars
	volume = 10000
	bullet_act()
		return
	ex_act()
		return
	electric_expose()
		return
	meteorhit()
		return
	temperature_expose()
		return
	blob_act()
		return

	anchored
		anchored = ANCHORED_ALWAYS


//Pod Wars space suits and helmets


//Suits
/obj/item/clothing/suit/space/pod_wars
	name = "pod wars space suit"

	setupProperties()
		..()
		setProperty("chemprot",60)
		setProperty("space_movespeed", 0)

	#ifdef MAP_OVERRIDE_POD_WARS // probably dont need this but just in case someone spawns it in normal round i guess
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, SPAN_ALERT("[src] <b>explodes</b> as you reach out to grab it!"))
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif

/obj/item/clothing/suit/space/pod_wars/NT
	name = "nanotrasen pod pilot suit"
	desc = "A space suit worn by Nanotrasen pod pilots."
	icon_state = "nanotrasen_pilot"
	item_state = "nanotrasen_pilot"
	team_num = TEAM_NANOTRASEN

/obj/item/clothing/suit/space/pod_wars/NT/commander
	name = "commander's great coat"
	icon_state = "ntcommander_coat"
	item_state = "ntcommander_coat"
	desc = "A fear-inspiring, blue-ish-leather great coat, typically worn by a NanoTrasen Pod Commander."

	setupProperties()
		..()
		setProperty("exploprot", 40)
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 3)
		setProperty("radprot", 50)

/obj/item/clothing/suit/space/pod_wars/NT/industrial
	name = "nanotrasen industrial space suit"
	item_state = "indus_specialist"
	icon_state = "indus_specialist"
	desc = "A durable space suit designed to protect from explosions and radiation. It is in Nanotrasen blue."

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("coldprot", 75)
		setProperty("heatprot", 25)
		setProperty("exploprot", 30)
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1)

/obj/item/clothing/suit/space/pod_wars/SY
	name = "syndicate pod pilot suit"
	desc = "A space suit worn by Syndicate pod pilots."
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	team_num = TEAM_SYNDICATE

/obj/item/clothing/suit/space/pod_wars/SY/commander
	name = "commander's great coat"
	icon_state = "commissar_greatcoat"
	desc = "A fear-inspiring, black-leather great coat, typically worn by a Syndicate Pod Commander."

	setupProperties()
		..()
		setProperty("exploprot", 40)
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 3)
		setProperty("radprot", 50)

/obj/item/clothing/suit/space/pod_wars/SY/industrial
	name = "syndicate industrial space suit"
	item_state = "indusred"
	icon_state = "indusred"
	desc = "A durable space suit designed to protect from explosions and radiation. It is in Syndicate red."

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("coldprot", 75)
		setProperty("heatprot", 25)
		setProperty("exploprot", 30)
		setProperty("meleeprot", 5)
		setProperty("rangedprot", 1)

//Helmets
/obj/item/clothing/head/helmet/space/pod_wars
	name = "pod wars space helmet"

	New()
		..()
		setProperty("chemprot",30)
		setProperty("heatprot", 15)
		setProperty("space_movespeed", 0)

	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, SPAN_ALERT("[src] <b>explodes</b> as you reach out to grab it!"))
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif

/obj/item/clothing/head/helmet/space/pod_wars/NT
	name = "nanotrasen pilot helmet"
	icon_state = "nanotrasen_pilot"
	item_state = "nanotrasen_pilot"
	desc = "A space helmet used by certain Nanotrasen pod pilots."
	team_num = TEAM_NANOTRASEN

/obj/item/clothing/head/helmet/space/pod_wars/NT/commander
	name = "nanotrasen commander's beret"
	desc = "For the inner space commander in you."
	icon_state = "ntberet_commander"
	item_state = "ntberet_commander"
	seal_hair = 0
	see_face = TRUE

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 5)
		setProperty("meleeprot_head", 4)

/obj/item/clothing/head/helmet/space/pod_wars/NT/industrial
	name = "nanotrasen industrial mining helmet"
	desc = "A reinforced mining space helmet used by Nanotrasen miners."
	icon_state = "EOD"
	item_state = "EOD"

	setupProperties()
		..()
		setProperty("meleeprot_head", 4)
		setProperty("radprot", 50)
		setProperty("exploprot", 10)

/obj/item/clothing/head/helmet/space/pod_wars/SY
	name = "syndicate pilot helmet"
	desc = "A space helmet used by certain Syndicate pod pilots."
	icon_state = "syndie_specialist"
	item_state = "syndie_specialist"
	team_num = TEAM_SYNDICATE

/obj/item/clothing/head/helmet/space/pod_wars/SY/commander
	name = "syndicate commander's cap"
	icon_state = "syndie_commander"
	desc = "For the inner space commander in you."
	seal_hair = 0
	see_face = TRUE

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 5)
		setProperty("meleeprot_head", 4)

/obj/item/clothing/head/helmet/space/pod_wars/SY/industrial
	name = "syndicate industrial mining helmet"
	desc = "A reinforced mining space helmet used by Syndicate miners."
	icon_state = "indusred"
	item_state = "indusred"

	setupProperties()
		..()
		setProperty("meleeprot_head", 4)
		setProperty("radprot", 50)
		setProperty("exploprot", 10)

//End of Pod Wars space suits and helmets

/obj/item/storage/pouch/highcap/pod_wars
	name = "tactical pouch"
	desc = "A large pouch for carrying multiple miscellaneous things at once."
	icon_state = "ammopouch-quad"
	w_class = W_CLASS_SMALL
	max_wclass = W_CLASS_NORMAL
	slots = 4
	opens_if_worn = TRUE
	can_hold = null
