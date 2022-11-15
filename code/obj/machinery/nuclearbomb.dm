/obj/machinery/nuclearbomb
	name = "nuclear bomb"
	desc = "An extremely powerful bomb capable of levelling the whole station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb"//1"
	density = 1
	anchored = 0
	event_handler_flags = IMMUNE_MANTA_PUSH
	_health = 150
	_max_health = 150
	var/armed = 0
	var/det_time = 0
	var/timer_default = 10 MINUTES
	var/timer_modifier_disk = 3 MINUTES // +3 (crew member) or -3 (nuke ops) min.
	var/motion_sensor_triggered = 0
	var/done = 0
	var/debugmode = 0
	var/datum/hud/nukewires/wirepanel
	var/obj/item/disk/data/floppy/read_only/authentication/disk = null
	var/isitspacemas = 0

	var/target_override = null // varedit to an area TYPE to allow the nuke to be deployed in that area instead of whatever the mode says (also enables the bomb in non-nuke gamemodes)
	var/target_override_name = "" // how the area gets displayed if you try to deploy the nuke in a wrong area
	var/anyone_can_activate = 0 // allows non-nukies to deploy the bomb
	var/boom_size = "nuke" // varedit to number to get an explosion instead

	var/started_light_animation = 0

	flags = FPRINT
	var/image/image_light = null
	p_class = 1.5

	New()
		wirepanel = new(src)
		#ifdef XMAS
		icon_state = "nuke_gift[rand(1,2)]"
		isitspacemas = "1"
		#endif
		image_light = image(src.icon, "nblight1")
		src.UpdateOverlays(src.image_light, "light")
		src.maptext_x = -16
		src.maptext_y = 4

		src.maptext_width = 64

		START_TRACKING
		..()

	disposing()
		STOP_TRACKING
		if(ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			gamemode.the_bomb = null
		qdel(wirepanel)
		..()

	process()
		if (done)
			qdel(src)
			return
		if (!armed)
			return

		var/turf/T = get_turf(src)
		if (T && istype(T))
			for (var/obj/shrub/S in T.contents)
				S.visible_message("<span class='alert'>[S] cannot withstand the intense radiation and crumbles to pieces!</span>")
				qdel(S)

		if(det_time && src.simple_light && !src.started_light_animation && det_time - TIME <= 2 MINUTES)
			src.started_light_animation = 1
			var/matrix/trans = matrix()
			trans.Scale(3)
			animate(src.simple_light, time = 2 MINUTES, alpha = 255, color = "#ff4444", transform = trans)

		if (det_time && TIME >= det_time)
			SPAWN(0)
				explode()
			src.maptext = "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">--:--</span>"
		else
			src.maptext = "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">[get_countdown_timer()]</span>"
		return

	examine(mob/user)
		. = ..()
		if(user.client)
			if (src.armed)
				. += "It is currently counting down to detonation. Ohhhh shit."
				. += "The timer reads [get_countdown_timer()].[src.disk && istype(src.disk) ? " The authenticaion disk has been inserted." : ""]"
			else
				. += "It is not armed. That's a relief."
				if (src.disk && istype(src.disk))
					. += "The authenticaion disk has been inserted."

			if (!src.anchored)
				. += "The floor bolts are unsecure. The bomb can be moved around."
			else
				. += "It is firmly anchored to the floor by its floor bolts."

			switch(src._health)
				if(80 to 125)
					. += "<span class='alert'>It is a little bit damaged.</span>"
				if(40 to 79)
					. += "<span class='alert'>It looks pretty beaten up.</span>"
				if(1 to 39)
					. += "<span class='alert'><b>It seems to be on the verge of falling apart!</b></span>"

	// Nuke round development was abandoned for 4 whole months, so I went out of my way to implement some user feedback from that 11 pages long forum thread (Convair880).
	attack_hand(mob/user)
		if (src.debugmode)
			open_wire_panel(user)
			return
		if (!user.mind || BOUNDS_DIST(src, user) > 0)
			return

		user.lastattacked = src

		var/datum/game_mode/nuclear/gamemode = ticker?.mode
		ENSURE_TYPE(gamemode)

		var/target_area = src.target_override
		if(isnull(target_area))
			target_area = gamemode?.target_location_type
		var/target_name = src.target_override_name
		if(!target_name && ispath(src.target_override))
			var/area/TA = src.target_override
			target_name = initial(TA.name)
		else if(!target_name && istype(gamemode))
			target_name = gamemode?.concatenated_location_names

		#define NUKE_AREA_CHECK (!src.armed && isturf(src.loc) && (\
				(ispath(target_area) && istype(get_area(src), target_area)) || \
				(islist(target_area) && ((get_area(src)):type in target_area)) \
			))

		if(!src.target_override && !istype(ticker?.mode, /datum/game_mode/nuclear))
			boutput(user, "<span class='alert'>[src.name] seems to be completely inert and useless.</span>")
		else if(src.armed)
			if (user.mind in gamemode?.syndicates)
				boutput(user, "<span class='notice'>You don't need to do anything else with the bomb.</span>")
			else
				user.visible_message("<span class='alert'><b>[user]</b> kicks [src] uselessly!</span>")
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
		else if(!src.anyone_can_activate && !(user.mind in gamemode?.syndicates))
			boutput(user, "<span class='alert'>It isn't deployed, and you don't know how to deploy it anyway.</span>")
		else if (!target_area)
			stack_trace("Nuclear bomb deployment area definition missing or invalid")
			boutput(user, "<span class='alert'>Deployment area definition missing or invalid! Please report this to a coder.</span>")
		else if (!NUKE_AREA_CHECK)
			boutput(user, "<span class='alert'>You need to deploy the bomb in [target_name].</span>")
		else if(tgui_alert(user, "Deploy and arm [src] here?", src.name, list("Yes", "No")) != "Yes")
			return
		else if(src.armed || !NUKE_AREA_CHECK || !can_reach(user, src) || !can_act(user)) // gotta re-check after the alert!!!
			boutput(user, "<span class='alert'>Deploying aborted due to you or [src] not being in [target_name].</span>")
		else
			src.armed = TRUE
			src.anchored = TRUE
			if (!src.image_light)
				src.image_light = image(src.icon, "nblightc")
				src.UpdateOverlays(src.image_light, "light")
			else
				src.image_light.icon_state = "nblightc"
				src.UpdateOverlays(src.image_light, "light")
			src.det_time = TIME + src.timer_default
			src.add_simple_light("nuke", list(255, 127, 127, 127))
			command_alert("\A [src] has been armed in [isturf(src.loc) ? get_area(src) : src.loc]. It will detonate in [src.get_countdown_timer()] minutes. All personnel must report to [get_area(src)] to disarm the bomb immediately.", "Nuclear Weapon Detected")
			playsound_global(world, 'sound/machines/bomb_planted.ogg', 75)
			logTheThing(LOG_GAMEMODE, user, "armed [src] at [log_loc(src)].")
			gamemode?.shuttle_available = FALSE

		#undef NUKE_AREA_CHECK

	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src

		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			if (istype(W, /obj/item/disk/data/floppy/read_only/authentication))
				if (src.disk && istype(src.disk))
					boutput(user, "<span class='alert'>There's already something in the [src.name]'s disk drive.</span>")
					return
				if (src.armed == 0)
					boutput(user, "<span class='alert'>The [src.name] isn't armed yet.</span>")
					return

				var/timer_modifier = 0
				if (user.mind in gamemode.syndicates)
					timer_modifier = -src.timer_modifier_disk
					user.visible_message("<span class='alert'><b>[user]</b> inserts [W.name], shortening the bomb's timer by [src.timer_modifier_disk / 10] seconds!</span>")
				else
					timer_modifier = src.timer_modifier_disk
					user.visible_message("<span class='alert'><b>[user]</b> inserts [W.name], extending the bomb's timer by [src.timer_modifier_disk / 10] seconds!</span>")

					if (user.mind && user.mind.assigned_role == "Captain") //the fat frog did it!
						user.unlock_medal("Brown Pants", 1)

					if(istype(ticker.mode, /datum/game_mode/nuclear))
						ticker.mode.shuttle_available = 1

				playsound(src.loc, 'sound/machines/ping.ogg', 100, 0)
				logTheThing(LOG_GAMEMODE, user, "inserted [W.name] into [src] at [log_loc(src)], modifying the timer by [timer_modifier / 10] seconds.")
				user.u_equip(W)
				W.set_loc(src)
				src.disk = W
				src.det_time += timer_modifier
				attack_particle(user,src)
				return

			if (istype(W, /obj/item/remote/syndicate_teleporter))
				for(var/obj/submachine/syndicate_teleporter/S in get_turf(src)) //sender
					for_by_tcl(R, /obj/submachine/syndicate_teleporter) // receiver
						if(R.id == S.id && S != R)
							if(S.recharging == 1)
								return
							if(R.recharging == 1)
								return
							else
								R.recharging = 1
								S.recharging = 1
								src.set_loc(R.loc)
								showswirl(src.loc)
								SPAWN(S.recharge)
									S.recharging = 0
								SPAWN(R.recharge)
									R.recharging = 0

			if (user.mind in gamemode.syndicates && !src.anyone_can_activate)
				if (src.armed == 1)
					boutput(user, "<span class='notice'>You don't need to do anything else with the bomb.</span>")
					return
				else
					boutput(user, "<span class='alert'>Why would you want to damage the nuclear bomb?</span>")
					return

			if (src.armed && src.anchored && !(user.mind in gamemode.syndicates))
				if (isscrewingtool(W))
					// Give the player a notice so they realize what has happened
					boutput(user, "<span class='alert'>The screws are all weird safety-bit types! You can't turn them!</span>")
					return

		if (istype(W, /obj/item/wrench/battle) && src._health <= src._max_health)
			SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, /obj/machinery/nuclearbomb/proc/repair_nuke, null, 'icons/obj/items/tools/wrench.dmi', "battle-wrench", "[user] repairs the [src]!", null)
			return

		if (W && !(istool(W, TOOL_SCREWING | TOOL_SNIPPING) || istype(W, /obj/item/disk/data/floppy/read_only/authentication)))
			switch (W.force)
				if (0 to 19)
					src.take_damage(W.force / 4)
				if (20 to 39)
					src.take_damage(W.force / 5)
				if (40 to 59)
					src.take_damage(W.force / 6)
				if (60 to INFINITY)
					src.take_damage(W.force / 7) // Esword has 60 force.

			logTheThing(LOG_COMBAT, user, "attacks [src] with [W] at [log_loc(src)].")
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
			attack_particle(user,src)

		return

	ex_act(severity)
		// No more suicide-bombing the nuke.
		return

	blob_act(var/power)
		if (!isnum(power) || power < 1) power = 1
		src.take_damage(power)
		return

	meteorhit()
		src.take_damage(rand(30,60))

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/6)*P.proj_data.ks_ratio), 1.0)

		if(src.material) src.material.triggerOnBullet(src, src, P)

		if (damage <= 0)
			return
		if(P.proj_data.damage_type == D_KINETIC || (P.proj_data.damage_type == D_ENERGY && damage))
			src.take_damage(damage / 3)
		else if (P.proj_data.damage_type == D_PIERCING)
			src.take_damage(damage)

	proc/repair_nuke()
		src._health = min(src._health+5, src._max_health)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		return

	proc/open_wire_panel(var/mob/user)
		user.s_active = src.wirepanel
		wirepanel.update()
		user.attach_hud(src.wirepanel)

	proc/get_countdown_timer()
		var/timeleft = round((det_time - TIME)/10 ,1)
		timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"
		return timeleft

	proc/take_damage(var/amount)
		if(startswith(src.icon_state, "nuclearbomb") && src.icon == initial(src.icon))
			switch(src._health)
				if(80 to 125)
					src.icon_state = "nuclearbomb1"
				if(40 to 80)
					src.icon_state = "nuclearbomb2"
				if(1 to 40)
					src.icon_state = "nuclearbomb3"
		if (!isnum(amount) || amount < 1)
			return
		src._health = max(0,src._health - amount)
		if (src._health < 1)
			src.visible_message("<b>[src]</b> breaks and falls apart into useless pieces!")
			robogibs(src.loc,null)
			playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 2)
			var/datum/game_mode/nuclear/gamemode = null
			if(ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
				gamemode = ticker.mode
				gamemode.the_bomb = null
				logTheThing(LOG_GAMEMODE, null, "The nuclear bomb was destroyed at [log_loc(src)].")
				message_admins("The nuclear bomb was destroyed at [log_loc(src)].")
			qdel(src)

	proc/explode()
		sleep(2 SECONDS)
		done = 1
		if(src.boom_size != "nuke")
			var/area/A = get_area(src)
			command_alert("\A [src] has been detonated in [A].", "Attention")
			explosion_new(src, get_turf(src), src.boom_size)
			qdel(src)
			return
		var/datum/game_mode/nuclear/gamemode = ticker?.mode
		var/turf/nuke_turf = get_turf(src)
		var/area/nuke_area = get_area(src)
		var/area_correct = 0
		if(src.target_override && istype(nuke_area, src.target_override))
			area_correct = 1
		if(istype(ticker?.mode, /datum/game_mode/nuclear) && istype(nuke_area, gamemode.target_location_type))
			area_correct = 1
		if ((nuke_turf.z != 1 && !area_correct) && (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear)))
			gamemode.the_bomb = null
			command_alert("A nuclear explosive has been detonated nearby. The station was not in range of the blast.", "Attention")
			explosion(src, src.loc, 20, 30, 40, 50)
			qdel(src)
			return
		explosion(src, src.loc, 35, 45, 55, 55)
#ifdef MAP_OVERRIDE_MANTA
		world.showCinematic("manta_nukies")
#else
		var/datum/hud/cinematic/cinematic = new
		for (var/client/C in clients)
			cinematic.add_client(C)
		cinematic.play("nuke")
#endif
		if(istype(gamemode))
			gamemode.nuke_detonated = 1
			gamemode.check_win()
		sleep(5.5 SECONDS)

		enter_allowed = 0
		for(var/mob/living/carbon/human/nukee in mobs)
			// cogwerks - making the end of nuke more exciting. oh no a nuke went off, let's all... stand around for thirty seconds
			if(!nukee.stat)
				nukee.emote("scream")
			// until we can fix the lag related to deleting mobs we should probably just leave the end of the animation up and kill everyone instead of firegibbing everyone
			nukee.death()//firegib()

		creepify_station()

		if(!istype(gamemode))
			sleep(1 SECOND)
			boutput(world, "<B>Everyone was killed by the nuclear blast! Resetting in 30 seconds!</B>")

			sleep(30 SECONDS)
			logTheThing(LOG_DIARY, null, "Rebooting due to nuclear destruction of station", "game")
			Reboot_server()

/datum/action/bar/icon/unanchorNuke
	duration = 55
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "unanchornuke"
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	icon_state = "screwdriver"
	var/obj/machinery/nuclearbomb/the_bomb = null

	New(Target)
		the_bomb = Target
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, the_bomb) > 0 || the_bomb == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!the_bomb.anchored)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, the_bomb) > 0 || the_bomb == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><b>[owner]</b> begins to unscrew [the_bomb]'s floor bolts.</span>", 1)

	onEnd()
		..()
		if (owner && the_bomb)
			var/timer_modifier = round((the_bomb.det_time - TIME) / 2)
			the_bomb.anchored = 0

			for (var/mob/O in AIviewers(owner))
				O.show_message("<span class='alert'><b>[owner]</b> unscrews [the_bomb]'s floor bolts.</span>", 1)

			if (TIME < (the_bomb.det_time - timer_modifier) && !the_bomb.motion_sensor_triggered)
				the_bomb.motion_sensor_triggered = 1
				the_bomb.det_time -= timer_modifier
				the_bomb.visible_message("<span class='alert'><b>[the_bomb]'s motion sensor was triggered! The countdown has been halved to [the_bomb.get_countdown_timer()]!</b></span>")
				logTheThing(LOG_GAMEMODE, owner, "unscrews [the_bomb] at [log_loc(the_bomb)], halving the countdown to [the_bomb.get_countdown_timer()].")

/obj/machinery/nuclearbomb/event
	anyone_can_activate = 1
	target_override = /area
	target_override_name = "anywhere"

/obj/machinery/nuclearbomb/event/micronuke
	name = "micronuke"
	desc = "A moderately powerful bomb capable of levelling most of a room."
	boom_size = 212
	_health = 75
	_max_health = 75
	timer_default = 5 MINUTES
	timer_modifier_disk = 1.5 MINUTES
	p_class = 1

	New()
		. = ..()
		src.SafeScale(0.75, 0.75)

/obj/bomb_decoy
	name = "nuclear bomb"
	desc = "An extremely powerful balloon capable of deceiving the whole station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb"
	density = 1
	anchored = 0
	_health = 10

	proc/checkhealth()
		if (src._health <= 0)
			src.visible_message("<span class='alert'><b>[src] pops!</b></span>")
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			var/obj/decal/cleanable/balloon/decal = make_cleanable(/obj/decal/cleanable/balloon,src.loc)
			decal.icon_state = "balloon_green_pop"
			qdel(src)

	attackby(var/obj/item/W, mob/user)
		..()
		user.lastattacked = src
		playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_1.ogg', 100, 1)
		src._health -= W.force
		checkhealth()
		return
