ADMIN_INTERACT_PROCS(/obj/machinery/nuclearbomb, proc/arm, proc/set_time_left)

/obj/machinery/nuclearbomb
	name = "nuclear bomb"
	desc = "An extremely powerful bomb capable of levelling the whole station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb"//1"
	density = 1
	anchored = UNANCHORED
	event_handler_flags = IMMUNE_MANTA_PUSH
	_health = 150
	_max_health = 150
	processing_tier = PROCESSING_FULL
	var/armed = FALSE
	var/det_time = 0
	var/timer_default = 10 MINUTES
	var/timer_modifier_disk = 3 MINUTES // +3 (crew member) or -3 (nuke ops) min.
	var/motion_sensor_triggered = 0
	var/done = 0
	var/debugmode = 0
	var/datum/hud/nukewires/wirepanel
	var/obj/item/disk/data/floppy/read_only/authentication/disk = null

	var/target_override = null // varedit to an area TYPE to allow the nuke to be deployed in that area instead of whatever the mode says (also enables the bomb in non-nuke gamemodes)
	var/target_override_name = "" // how the area gets displayed if you try to deploy the nuke in a wrong area
	var/anyone_can_activate = 0 // allows non-nukies to deploy the bomb
	var/boom_size = "nuke" // varedit to number to get an explosion instead

	var/started_light_animation = 0
	///Does this nuke give the "brown pants" medal when authed by a captain? Only true by default for the specific nuke spawned by the nukies gamemode
	var/gives_medal = FALSE
	///skips the prompt asking if you want to arm the bomb. For 'pranks'
	var/no_warning = FALSE

	var/image/image_light = null
	p_class = 1.5

	New()
		wirepanel = new(src)
		#ifdef XMAS
		icon_state = "nuke_gift[rand(1,2)]"
		#endif
		image_light = image(src.icon, "nblight1")

		src.UpdateOverlays(src.image_light, "light")
		src.maptext_x = -16
		src.maptext_y = 4
		src.maptext_width = 64

		// For status display updating
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, null, FREQ_STATUS_DISPLAY)

		get_self_and_decoys() // links them up

		START_TRACKING
		..()

	disposing()
		STOP_TRACKING
		if(ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			if(gamemode.the_bomb == src)
				gamemode.the_bomb = null
				STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)
		qdel(wirepanel)
		..()

	proc/get_self_and_decoys()
		RETURN_TYPE(/list/obj)
		. = list(src)
		for_by_tcl(decoy, /obj/bomb_decoy)
			if(decoy.is_linked_to_bomb(src))
				. += decoy

	process()
		if (done)
			qdel(src)
			return
		if (!armed)
			return

		var/turf/T = get_turf(src)
		if (T && istype(T))
			for (var/obj/shrub/S in T.contents)
				S.visible_message(SPAN_ALERT("[S] cannot withstand the intense radiation and crumbles to pieces!"))
				qdel(S)

		if(det_time && src.simple_light && !src.started_light_animation && det_time - TIME <= 2 MINUTES)
			src.started_light_animation = 1
			var/matrix/trans = matrix()
			trans.Scale(3)
			for(var/obj/bomb_or_decoy as anything in get_self_and_decoys())
				animate(bomb_or_decoy.simple_light, time = 2 MINUTES, alpha = 255, color = "#ff4444", transform = trans)

		var/timer_string = null
		if (det_time && TIME >= det_time)
			SPAWN(0)
				explode()
			timer_string = "--:--"
		else
			timer_string = get_countdown_timer()

		for(var/obj/bomb_or_decoy as anything in get_self_and_decoys())
			bomb_or_decoy.maptext = "<span style=\"color: red; font-family: Fixedsys, monospace; text-align: center; vertical-align: top; -dm-text-outline: 1 black;\">[timer_string]</span>"


	proc/set_time_left()
		if (!src.armed)
			var/input = input(usr, "Enter new timer duration (s)", "Set timer", src.timer_default/10) as num | null
			if (!isnull(input))
				src.timer_default = input SECONDS
		else
			var/current_time_left = (src.det_time - TIME)/10
			var/input = input(usr, "Modify timer duration (s)", "Set timer", current_time_left) as num | null
			if (!isnull(input))
				src.det_time = TIME + input SECONDS

	proc/base_desc()
		. = list()
		if (src.armed)
			. += "It is currently counting down to detonation. Ohhhh shit."
			. += "The timer reads [get_countdown_timer()].[src.disk && istype(src.disk) ? " The authentication disk has been inserted." : ""]"
		else
			. += "It is not armed. That's a relief."
			if (src.disk && istype(src.disk))
				. += "The authentication disk has been inserted."

		if (!src.anchored)
			. += "The floor bolts are unsecure. The bomb can be moved around."
		else
			. += "It is firmly anchored to the floor by its floor bolts."
		. = jointext(., " ")

	get_desc(dist, mob/user)
		. = ..() + base_desc()
		switch(src._health)
			if(80 to 125)
				. += SPAN_ALERT("It is a little bit damaged.")
			if(40 to 79)
				. += SPAN_ALERT("It looks pretty beaten up.")
			if(1 to 39)
				. += SPAN_ALERT("<b>It seems to be on the verge of falling apart!</b>")

	// Nuke round development was abandoned for 4 whole months, so I went out of my way to implement some user feedback from that 11 pages long forum thread (Convair880).
	attack_hand(mob/user)
		if (src.debugmode)
			open_wire_panel(user)
			return
		if (!user.mind || BOUNDS_DIST(src, user) > 0 || isintangible(user))
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
				(islist(target_area) && istypes(get_area(src), target_area)) \
			))

		if(!src.target_override && !istype(ticker?.mode, /datum/game_mode/nuclear))
			boutput(user, SPAN_ALERT("[src.name] seems to be completely inert and useless."))

		else if(src.armed)
			if (user.mind in gamemode?.syndicates)
				boutput(user, SPAN_NOTICE("You don't need to do anything else with the bomb."))
			else
				user.visible_message(SPAN_ALERT("<b>[user]</b> kicks [src] uselessly!"))
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
		else if(!src.anyone_can_activate && !(user.mind in gamemode?.syndicates))
			boutput(user, SPAN_ALERT("It isn't deployed, and you don't know how to deploy it anyway."))
		else if (!target_area)
			stack_trace("Nuclear bomb deployment area definition missing or invalid")
			boutput(user, SPAN_ALERT("Deployment area definition missing or invalid! Please report this to a coder."))
		else if (!NUKE_AREA_CHECK)
			boutput(user, SPAN_ALERT("You need to deploy the bomb in [target_name]."))
		else if(no_warning ? FALSE : (tgui_alert(user, "Deploy and arm [src] here?", src.name, list("Yes", "No")) != "Yes"))
			return
		else if(src.armed || !NUKE_AREA_CHECK || !can_reach(user, src) || !can_act(user)) // gotta re-check after the alert!!!
			boutput(user, SPAN_ALERT("Deploying aborted due to you or [src] not being in [target_name]."))
		else
			src.arm(user)

		#undef NUKE_AREA_CHECK

	proc/arm(mob/user)
		if (src.armed)
			return
		src.armed = TRUE
		src.anchored = ANCHORED
		if (src.z == Z_LEVEL_STATION && src.boom_size == "nuke")
			src.change_status_display()
		if (!src.image_light)
			src.image_light = image(src.icon, "nblightc")
			for(var/obj/bomb_or_decoy as anything in get_self_and_decoys())
				bomb_or_decoy.UpdateOverlays(src.image_light, "light")
		else
			src.image_light.icon_state = "nblightc"
			for(var/obj/bomb_or_decoy as anything in get_self_and_decoys())
				bomb_or_decoy.UpdateOverlays(src.image_light, "light")
		src.det_time = TIME + src.timer_default
		for(var/obj/bomb_or_decoy as anything in get_self_and_decoys())
			bomb_or_decoy.add_simple_light("nuke", list(255, 127, 127, 127))
		command_alert("\A [src] has been armed in [isturf(src.loc) ? get_area(src) : src.loc]. It will detonate in [src.get_countdown_timer()] minutes. All personnel must report to [get_area(src)] to disarm the bomb immediately.", "Nuclear Weapon Detected")
		if (!ON_COOLDOWN(global, "nuke_planted", 20 SECONDS))
			playsound_global(world, 'sound/machines/bomb_planted.ogg', 75)
		logTheThing(LOG_GAMEMODE, user, "armed [src] at [log_loc(src)].")
		message_ghosts("<b>[src]</b> has been armed at [log_loc(src.loc, ghostjump=TRUE)].")
		var/datum/game_mode/nuclear/gamemode = ticker?.mode
		ENSURE_TYPE(gamemode)
		gamemode?.shuttle_available = SHUTTLE_AVAILABLE_DISABLED

	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src

		if (istype(W, /obj/item/disk/data/floppy/read_only/authentication))
			if (src.disk && istype(src.disk))
				boutput(user, SPAN_ALERT("There's already something in the [src.name]'s disk drive."))
				return
			if (!src.armed)
				boutput(user, SPAN_ALERT("The [src.name] isn't armed yet."))
				return

			var/timer_modifier = 0
			if (isnukeop(user))
				timer_modifier = -src.timer_modifier_disk
				user.visible_message(SPAN_ALERT("<b>[user]</b> inserts [W.name], shortening the bomb's timer by [src.timer_modifier_disk / 10] seconds!"))
			else
				timer_modifier = src.timer_modifier_disk
				user.visible_message(SPAN_ALERT("<b>[user]</b> inserts [W.name], extending the bomb's timer by [src.timer_modifier_disk / 10] seconds!"))

				if (user.mind?.assigned_role == "Captain" && src.gives_medal) //the fat frog did it!
					user.unlock_medal("Brown Pants", 1)

				if(istype(ticker.mode, /datum/game_mode/nuclear))
					ticker.mode.shuttle_available = SHUTTLE_AVAILABLE_NORMAL

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

		if (isnukeop(user) && !src.anyone_can_activate)
			if (src.armed == 1)
				boutput(user, SPAN_NOTICE("You don't need to do anything else with the bomb."))
				return
			else
				boutput(user, SPAN_ALERT("Why would you want to damage the nuclear bomb?"))
				return

		if (src.armed && src.anchored && !isnukeop(user))
			if (isscrewingtool(W))
				// Give the player a notice so they realize what has happened
				boutput(user, SPAN_ALERT("The screws are all weird safety-bit types! You can't turn them!"))
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

		src.material_trigger_on_bullet(src, P)

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
		if(QDELETED(src))
			return
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
			robogibs(src.loc)
			playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 2)
			var/datum/game_mode/nuclear/gamemode = null
			if(ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear) && src.boom_size == "nuke")
				gamemode = ticker.mode
				gamemode.the_bomb = null
				logTheThing(LOG_GAMEMODE, null, "The nuclear bomb was destroyed at [log_loc(src)].")
				message_admins("The nuclear bomb was destroyed at [log_loc(src)].")
				message_ghosts("<b>[src]</b> was destroyed at [log_loc(src, ghostjump=TRUE)]!")
			qdel(src)

	proc/explode()
		sleep(2 SECONDS)
		if(QDELETED(src) || done)
			return
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

		// Don't re-enable the explosion without asking me first -ZeWaka

		if ((nuke_turf?.z != 1 && !area_correct) && (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear)))
			gamemode.the_bomb = null
			command_alert("A nuclear explosive has been detonated nearby. The station was not in range of the blast.", "Attention")
			//explosion(src, src.loc, 20, 30, 40, 50)
			qdel(src)
			return
		//explosion(src, src.loc, 35, 45, 55, 55)


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
			if (!istype(nukee.loc, /obj/storage/secure/closet/fridge))
				nukee.death()//firegib()

		creepify_station()

		if(!istype(gamemode))
			sleep(1 SECOND)
			boutput(world, "<B>Everyone was killed by the nuclear blast! Resetting in 30 seconds!</B>")

			sleep(30 SECONDS)
			logTheThing(LOG_DIARY, null, "Rebooting due to nuclear destruction of station", "game")
			Reboot_server()

	proc/change_status_display()
		var/datum/signal/status_signal = get_free_signal()
		status_signal.source = src
		status_signal.transmission_method = TRANSMISSION_RADIO
		status_signal.data["command"] = "nuclear"
		status_signal.data["address_tag"] = "STATDISPLAY"

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, status_signal, null, FREQ_STATUS_DISPLAY)
/datum/action/bar/icon/unanchorNuke
	duration = 55
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
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
			O.show_message(SPAN_ALERT("<b>[owner]</b> begins to unscrew [the_bomb]'s floor bolts."), 1)

	onEnd()
		..()
		if (owner && the_bomb)
			var/timer_modifier = round((the_bomb.det_time - TIME) / 2)
			the_bomb.anchored = UNANCHORED

			for (var/mob/O in AIviewers(owner))
				O.show_message(SPAN_ALERT("<b>[owner]</b> unscrews [the_bomb]'s floor bolts."), 1)

			if (TIME < (the_bomb.det_time - timer_modifier) && !the_bomb.motion_sensor_triggered)
				the_bomb.motion_sensor_triggered = 1
				the_bomb.det_time -= timer_modifier
				the_bomb.visible_message(SPAN_ALERT("<b>[the_bomb]'s motion sensor was triggered! The countdown has been halved to [the_bomb.get_countdown_timer()]!</b>"))
				logTheThing(LOG_GAMEMODE, owner, "unscrews [the_bomb] at [log_loc(the_bomb)], halving the countdown to [the_bomb.get_countdown_timer()].")

/obj/machinery/nuclearbomb/event
	anyone_can_activate = 1
	target_override = /area
	target_override_name = "anywhere"

/obj/machinery/nuclearbomb/event/micronuke
	name = "micronuke"
	desc = "A powerful bomb capable of levelling a department and some more."
	boom_size = 1250
	_health = 75
	_max_health = 75
	timer_default = 5 MINUTES
	timer_modifier_disk = 1.5 MINUTES
	p_class = 1

	New()
		. = ..()
		src.SafeScale(0.75, 0.75)

/obj/machinery/nuclearbomb/event/micronuke/defended
	arm(mob/user)
		. = ..()
		for(var/turf/T in orange(1, get_turf(src)))
			if(isfloor(T))
				new /obj/critter/gunbot/drone/miniature_syndie/robust(T)

/obj/bomb_decoy
	name = "nuclear bomb"
	desc = ""
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb"
	density = 1
	anchored = UNANCHORED
	_health = 10
	var/datum/weakref/our_bomb = null
	var/recognizable_range = 2 //! people this far away and closer will see that this is a balloon in the description
	var/extremely_convincing = FALSE //! set to true to fool everyone in description, includidng nukies (using it will give it away still)

	New()
		..()
		#ifdef XMAS
		icon_state = "nuke_gift[rand(1,2)]"
		#endif
		START_TRACKING
		src.UpdateOverlays(image(src.icon, "nblight1"), "light")
		src.maptext_x = -16
		src.maptext_y = 4
		src.maptext_width = 64
		if(length(by_type[/obj/machinery/nuclearbomb]))
			src.our_bomb = get_weakref(pick(by_type[/obj/machinery/nuclearbomb]))

	proc/is_linked_to_bomb(obj/machinery/nuclearbomb/bomb)
		if(isnull(src.our_bomb?.deref()))
			src.our_bomb = get_weakref(bomb)
			return TRUE
		if(src.our_bomb.deref() == bomb)
			return TRUE
		return FALSE

	get_desc(dist, mob/user)
		var/can_user_recognize = !extremely_convincing && \
			( \
				user?.mind?.get_antagonist(ROLE_NUKEOP) || user?.mind?.get_antagonist(ROLE_NUKEOP_COMMANDER) || \
				dist <= src.recognizable_range || (FACTION_SYNDICATE in user?.faction) \
			)
		if(isnull(src.our_bomb?.deref()) || can_user_recognize)
			. = "<br>An extremely powerful balloon capable of deceiving the whole station."
		else
			var/obj/machinery/nuclearbomb/bomb = src.our_bomb.deref()
			. = list("<br>" + bomb.desc, " " + bomb.base_desc())

	disposing()
		STOP_TRACKING
		..()

	proc/checkhealth()
		if (src._health <= 0)
			src.visible_message(SPAN_ALERT("<b>[src] pops!</b>"))
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			var/obj/decal/cleanable/balloon/decal = make_cleanable(/obj/decal/cleanable/balloon,src.loc)
			decal.icon_state = "balloon_green_pop"
			qdel(src)

	attackby(var/obj/item/W, mob/user)
		..()
		if(iswrenchingtool(W))
			src.anchored = !src.anchored
			boutput(user, SPAN_NOTICE("[src] is now [src.anchored ? "anchored" : "unanchored"]."))
			return
		user.lastattacked = src
		playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_1.ogg', 100, 1)
		src._health -= W.force
		checkhealth()
