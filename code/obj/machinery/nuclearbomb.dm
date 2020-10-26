/obj/machinery/nuclearbomb
	name = "nuclear bomb"
	desc = "An extremely powerful bomb capable of levelling the whole station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb"//1"
	density = 1
	anchored = 0
	event_handler_flags = IMMUNE_MANTA_PUSH
	var/health = 150
	var/armed = 0
	var/det_time = 0
	var/timer_default = 6000 // 10 min.
	var/timer_modifier_disk = 1800 // +3 (crew member) or -3 (nuke ops) min.
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
		..()

	disposing()
		if(ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/NUKEMODE = ticker.mode
			NUKEMODE.the_bomb = null
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

		if(det_time && src.simple_light && !src.started_light_animation && det_time - ticker.round_elapsed_ticks <= 2 MINUTES)
			src.started_light_animation = 1
			var/matrix/trans = matrix()
			trans.Scale(3)
			animate(src.simple_light, time = 2 MINUTES, alpha = 255, color = "#ff4444", transform = trans)

		if (det_time && ticker.round_elapsed_ticks >= det_time)
			SPAWN_DBG(0)
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
				. += "The floor bolts have been unsecured. The bomb can be moved around."
			else
				. += "It is firmly anchored to the floor by its floor bolts. A screwdriver could undo them."

			switch(src.health)
				if(80 to 125)
					. += "<span class='alert'>It is a little bit damaged.</span>"
				if(40 to 79)
					. += "<span class='alert'>It looks pretty beaten up.</span>"
				if(1 to 39)
					. += "<span class='alert'><b>It seems to be on the verge of falling apart!</b></span>"

	// Nuke round development was abandoned for 4 whole months, so I went out of my way to implement some user feedback from that 11 pages long forum thread (Convair880).
	attack_hand(mob/user as mob)
		if (src.debugmode)
			open_wire_panel(user)
			return
		if (!user.mind || get_dist(src, user) > 1)
			return

		user.lastattacked = src

		var/datum/game_mode/nuclear/NUKEMODE = null
		var/area/A = get_area(src)



		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear) || src.target_override)
			NUKEMODE = ticker.mode
			var/target_area = src.target_override
			if(isnull(target_area))
				target_area = NUKEMODE.target_location_type
			var/target_name = src.target_override_name
			if(!target_name && ispath(src.target_override))
				var/area/TA = src.target_override
				target_name = initial(TA.name)
			else if(!target_name && istype(NUKEMODE))
				target_name = NUKEMODE.target_location_name

			if (src.armed == 0)
				if (src.anyone_can_activate || (istype(NUKEMODE, /datum/game_mode/nuclear) && (user.mind in NUKEMODE.syndicates)))
					if (target_area && (A && istype(A)))
						if (!((ispath(target_area) && istype(A, target_area)) || (islist(target_area) && (A.type in target_area))))
							boutput(user, "<span class='alert'>You need to deploy the bomb in [target_name].</span>")
						else
							if (alert("Deploy and arm [src.name] here?", src.name, "Yes", "No") == "Yes" && !src.armed && get_dist(src, user) <= 1 && !(user.getStatusDuration("stunned") > 0 || user.getStatusDuration("weakened") || user.getStatusDuration("paralysis") > 0 || !isalive(user) || user.restrained()))
								src.armed = 1
								src.anchored = 1
								if (!src.image_light)
									src.image_light = image(src.icon, "nblightc")
									src.UpdateOverlays(src.image_light, "light")
								else
									src.image_light.icon_state = "nblightc"
									src.UpdateOverlays(src.image_light, "light")
								//src.icon_state = "nuclearbomb2"
								src.det_time = ticker.round_elapsed_ticks + src.timer_default
								src.add_simple_light("nuke", list(255, 127, 127, 127))
								command_alert("\A [src] has been armed in [A]. It will detonate in [src.get_countdown_timer()] minutes. All personnel must report to [A] to disarm the bomb immediately.", "Nuclear Weapon Detected")
								world << sound('sound/machines/bomb_planted.ogg')
								logTheThing("bombing", user, null, "armed [src] at [log_loc(src)].")

					else
						boutput(user, "<span class='alert'>Deployment area definition missing or invalid! Please report this to a coder.</span>")
				else
					boutput(user, "<span class='alert'>It isn't deployed, and you don't know how to deploy it anyway.</span>")
			else
				if (istype(NUKEMODE, /datum/game_mode/nuclear) && (user.mind in NUKEMODE.syndicates))
					boutput(user, "<span class='notice'>You don't need to do anything else with the bomb.</span>")
				else
					user.visible_message("<span class='alert'><b>[user]</b> kicks [src] uselessly!</span>")
					playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
		else
			boutput(user, "<span class='alert'>[src.name] seems to be completely inert and useless.</span>")

		return

	attackby(obj/item/W as obj, mob/user as mob)
		src.add_fingerprint(user)
		user.lastattacked = src

		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/NUKEMODE = ticker.mode
			if (istype(W, /obj/item/disk/data/floppy/read_only/authentication))
				if (src.disk && istype(src.disk))
					boutput(user, "<span class='alert'>There's already something in the [src.name]'s disk drive.</span>")
					return
				if (src.armed == 0)
					boutput(user, "<span class='alert'>The [src.name] isn't armed yet.</span>")
					return

				var/timer_modifier = 0
				if (user.mind in NUKEMODE.syndicates)
					timer_modifier = -src.timer_modifier_disk
					user.visible_message("<span class='alert'><b>[user]</b> inserts [W.name], shortening the bomb's timer by [src.timer_modifier_disk / 10] seconds!</span>")
				else
					timer_modifier = src.timer_modifier_disk
					user.visible_message("<span class='alert'><b>[user]</b> inserts [W.name], extending the bomb's timer by [src.timer_modifier_disk / 10] seconds!</span>")

				playsound(src.loc, "sound/machines/ping.ogg", 100, 0)
				logTheThing("bombing", user, null, "inserted [W.name] into [src] at [log_loc(src)], modifying the timer by [timer_modifier / 10] seconds.")
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
								SPAWN_DBG(S.recharge)
									S.recharging = 0
								SPAWN_DBG(R.recharge)
									R.recharging = 0

			if (user.mind in NUKEMODE.syndicates && !src.anyone_can_activate)
				if (src.armed == 1)
					boutput(user, "<span class='notice'>You don't need to do anything else with the bomb.</span>")
					return
				else
					boutput(user, "<span class='alert'>Why would you want to damage the nuclear bomb?</span>")
					return

			if (src.armed && src.anchored && !(user.mind in NUKEMODE.syndicates))
				if (isscrewingtool(W))
					actions.start(new /datum/action/bar/icon/unanchorNuke(src), user)
					return
				//else if (istype(W,/obj/item/wirecutters/))
				//	user.visible_message("<b>[user]</b> opens up [src]'s wiring panel and takes a look.")
				//	open_wire_panel(user)
				//	return

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

			logTheThing("combat", user, null, "attacks [src] with [W] at [log_loc(src)].")
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
			attack_particle(user,src)

		..()
		return

	ex_act(severity)
		/*switch(severity) // No more suicide-bombing the nuke.
			if(1)
				src.take_damage(80)
			if(2)
				src.take_damage(50)
			if(3)
				src.take_damage(20)*/
		return

	blob_act(var/power)
		if (!isnum(power) || power < 1) power = 1
		src.take_damage(power)
		return

	emp_act()
		src.take_damage(rand(25,35))
		if (armed && det_time)
			det_time += rand(-300,600)

	meteorhit()
		src.take_damage(rand(30,60))

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/6)*P.proj_data.ks_ratio), 1.0)

		if(src.material) src.material.triggerOnBullet(src, src, P)

		if (!damage)
			return
		if(P.proj_data.damage_type == D_KINETIC || (P.proj_data.damage_type == D_ENERGY && damage))
			src.take_damage(damage / 1.7)
		else if (P.proj_data.damage_type == D_PIERCING)
			src.take_damage(damage)

	proc/open_wire_panel(var/mob/user)
		user.s_active = src.wirepanel
		wirepanel.update()
		user.attach_hud(src.wirepanel)

	proc/get_countdown_timer()
		var/timeleft = round((det_time - ticker.round_elapsed_ticks)/10 ,1)
		timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"
		return timeleft

	proc/take_damage(var/amount)
		if(!isitspacemas)
			switch(src.health)
				if(80 to 125)
					src.icon_state = "nuclearbomb1"
				if(40 to 80)
					src.icon_state = "nuclearbomb2"
				if(1 to 40)
					src.icon_state = "nuclearbomb3"
		if (!isnum(amount) || amount < 1)
			return
		src.health = max(0,src.health - amount)
		if (src.health < 1)
			src.visible_message("<b>[src]</b> breaks and falls apart into useless pieces!")
			robogibs(src.loc,null)
			playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 2)
			var/datum/game_mode/nuclear/NUKEMODE = null
			if(ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
				NUKEMODE = ticker.mode
				NUKEMODE.the_bomb = null
				logTheThing("station", null, null, "The nuclear bomb was destroyed at [log_loc(src)].")
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
		var/datum/game_mode/nuclear/NUKEMODE = ticker?.mode
		var/turf/nuke_turf = get_turf(src)
		var/area/nuke_area = get_area(src)
		var/area_correct = 0
		if(src.target_override && istype(nuke_area, src.target_override))
			area_correct = 1
		if(istype(ticker?.mode, /datum/game_mode/nuclear) && istype(nuke_area, NUKEMODE.target_location_type))
			area_correct = 1
		if ((nuke_turf.z != 1 && !area_correct) && (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear)))
			NUKEMODE.the_bomb = null
			command_alert("A nuclear explosive has been detonated nearby. The station was not in range of the blast.", "Attention")
			explosion(src, src.loc, 20, 30, 40, 50)
			qdel(src)
			return
#ifdef MAP_OVERRIDE_MANTA
		world.showCinematic("manta_nukies")
#else
		var/datum/hud/cinematic/cinematic = new
		for (var/client/C in clients)
			cinematic.add_client(C)
		cinematic.play("nuke")
#endif
		if(istype(NUKEMODE))
			NUKEMODE.nuke_detonated = 1
			NUKEMODE.check_win()
		sleep(5.5 SECONDS)

		enter_allowed = 0
		for(var/mob/living/carbon/human/nukee in mobs)
			// cogwerks - making the end of nuke more exciting. oh no a nuke went off, let's all... stand around for thirty seconds
			if(!nukee.stat)
				nukee.emote("scream")
			// until we can fix the lag related to deleting mobs we should probably just leave the end of the animation up and kill everyone instead of firegibbing everyone
			nukee.death()//firegib()

		creepify_station()

		if(!istype(NUKEMODE))
			sleep(1 SECOND)
			boutput(world, "<B>Everyone was killed by the nuclear blast! Resetting in 30 seconds!</B>")

			sleep(30 SECONDS)
			logTheThing("diary", null, null, "Rebooting due to nuclear destruction of station", "game")
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
		if(get_dist(owner, the_bomb) > 1 || the_bomb == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!the_bomb.anchored)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, the_bomb) > 1 || the_bomb == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><b>[owner]</b> begins to unscrew [the_bomb]'s floor bolts.</span>", 1)

	onEnd()
		..()
		if (owner && the_bomb)
			var/timer_modifier = round((the_bomb.det_time - ticker.round_elapsed_ticks) / 2)
			the_bomb.anchored = 0

			for (var/mob/O in AIviewers(owner))
				O.show_message("<span class='alert'><b>[owner]</b> unscrews [the_bomb]'s floor bolts.</span>", 1)

			if (ticker.round_elapsed_ticks < (the_bomb.det_time - timer_modifier) && !the_bomb.motion_sensor_triggered)
				the_bomb.motion_sensor_triggered = 1
				the_bomb.det_time -= timer_modifier
				the_bomb.visible_message("<span class='alert'><b>[the_bomb]'s motion sensor was triggered! The countdown has been halved to [the_bomb.get_countdown_timer()]!</b></span>")
				logTheThing("bombing", owner, null, "unscrews [the_bomb] at [log_loc(the_bomb)], halving the countdown to [the_bomb.get_countdown_timer()].")

/obj/machinery/nuclearbomb/event
	anyone_can_activate = 1
	target_override = /area
	target_override_name = "anywhere"
