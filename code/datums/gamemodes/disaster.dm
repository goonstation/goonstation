/datum/game_mode/disaster
	name = "disaster"
	config_tag = "disaster"

	var/disaster_type = 0
	var/disaster_name = "bad thing" //This should be set by the disaster start!!
	//Time before the disaster starts.
	var/const/waittime_l = 1000
	var/const/waittime_h = 1600
	//Time until the shuttle can be called.
	var/const/shuttle_waittime = 4000

/datum/game_mode/disaster/pre_setup()
	var/list/candidates = get_possible_enemies(ROLE_WRAITH, 0)
	if (length(candidates))
		var/datum/mind/twraith = pick(candidates) // Just one for now
		twraith.special_role = ROLE_WRAITH
		Agimmicks += twraith

	return 1

/datum/game_mode/disaster/announce()
	if(derelict_mode)
		boutput(world, "<tt>BUG: MEM ERR 0000FF88 00F90045</tt>")
		playsound_global(world, 'sound/machines/glitch1.ogg', 60)
		boutput(world, "<B>We are experiencing technical difficulties. Please remain calm. Help is on the way.</B>")
		boutput(world, "<B>Report to your station's emergency rally point: CHAPEL.</B>")
	else
		boutput(world, "<B>The current game mode is - Disaster!</B>")
		boutput(world, "<B>The station is in the middle of a cosmic disaster! You must escape or at least live!</B>")


/datum/game_mode/disaster/post_setup()
	for(var/datum/mind/wraith in Agimmicks)
		wraith.current.set_loc(pick_landmark(LANDMARK_OBSERVER, locate(150, 150, 1)))
		generate_wraith_objectives(wraith)

	emergency_shuttle.disabled = SHUTTLE_CALL_MANUAL_CALL_DISABLED //Disable the shuttle temporarily.

	if(derelict_mode)
		SPAWN(1 SECOND)
			var/list/CORPSES = landmarks[LANDMARK_PESTSTART]
			var/list/JUNK = landmarks[LANDMARK_HALLOWEEN_SPAWN]
			for(var/turf/T in CORPSES)
				var/obj/decal/fakeobjects/skeleton/S = new/obj/decal/fakeobjects/skeleton(T)
				S.name = "corpse"
				S.desc = "The mangled body of some poor [pick("chump","sap","chap","crewmember","jerk","dude","lady","idiot","employee","oaf")]."
				S.icon = 'icons/misc/hstation.dmi'
				S.icon_state = pick("body3","body4","body5","body6","body7","body8","clowncorpse")
			for(var/turf/T in JUNK)
				var/junk_type = rand(1,4)
				switch(junk_type)
					if(1)
						new/obj/candle_light(T)
					if(2)
						new/obj/item/spook(T)
					if(3)
						new/obj/critter/floateye(T)
					if(4)
						var/obj/item/device/light/glowstick/G = new/obj/item/device/light/glowstick(T)
						SPAWN(2 SECONDS)
							G.on = 1
							G.icon_state = "glowstick-on"
							G.light?.enable()

	var/start_wait = rand(waittime_l, waittime_h)

	SPAWN(start_wait)
		start_disaster()
//
	SPAWN(start_wait + shuttle_waittime)
		emergency_shuttle.disabled = SHUTTLE_CALL_ENABLED
		emergency_shuttle.incall()
		if(derelict_mode)
			command_alert("Ev4C**!on shu9999999__ called. Prepare fo# evacua ****SIGNAL LOST****","Emergency Al&RT")
			playsound_global(world, 'sound/machines/engine_alert2.ogg', 60)
		else
			command_alert("The shuttle has been called.","Emergency Shuttle Update")

	if(derelict_mode) // ready up some effects and noises
		SPAWN(0.2 SECONDS)
			for(var/mob/living/carbon/human/H in mobs)
				H.flash(3 SECONDS)

		SPAWN(10 SECONDS)
			playsound_global(world, 'sound/effects/creaking_metal1.ogg', 60)
			for(var/mob/living/carbon/human/H in mobs)
				shake_camera(H, 8, 32)
				H.change_misstep_chance(5)

		SPAWN(20 SECONDS)
			if(length(scarysounds))
				playsound_global(world, pick(scarysounds), 50)

		SPAWN(30 SECONDS)
			if(length(scarysounds))
				playsound_global(world, pick(scarysounds), 50)

		SPAWN(40 SECONDS)
			playsound_global(world, 'sound/effects/creaking_metal1.ogg', 60)
			for(var/mob/living/carbon/human/H in mobs)
				shake_camera(H, 8, 24)
				H.change_misstep_chance(5)

		SPAWN(1 MINUTE)
			playsound_global(world, 'sound/effects/creaking_metal1.ogg', 60)
			for(var/mob/living/carbon/human/H in mobs)
				shake_camera(H, 7, 16)
				H.change_misstep_chance(5)

		SPAWN(80 SECONDS)
			if(length(scarysounds))
				playsound_global(world, pick(scarysounds), 50)

	return

/datum/game_mode/disaster/declare_completion()
	var/list/survivors = list()

	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue

		if (!isdead(player))
			if (in_centcom(player))
				survivors[player.real_name] = "shuttle"
				player.unlock_medal("Icarus", 1)
			else
				survivors[player.real_name] = "alive"

	if (survivors.len)
		boutput(world, "<span class='notice'><B>The following survived the [disaster_name] event!</B></span>")
		for(var/survivor in survivors)
			var/condition = survivors[survivor]
			switch(condition)
				if("shuttle")
					boutput(world, "&emsp; <B><FONT size = 2>[survivor] escaped on the shuttle!</FONT></B>")
				if("alive")
					boutput(world, "&emsp; <FONT size = 1>[survivor] stayed alive. Whereabouts unknown.</FONT>")

	else
		boutput(world, "<span class='notice'><B>No one survived the [disaster_name] event!</B></span>")

#ifdef RP_MODE // if rp do not set to secret
		world.save_mode("extended")
		master_mode = "extended"
#else
		world.save_mode("secret") // set back to normal rotation
		master_mode = "secret"
#endif
	return 1


/datum/game_mode/disaster/proc/start_disaster()
	var/disaster_name1 = pick("Time ","Warp ","Quantum ","Robust ","Explosive ","Ion ","Cosmic ","Dimensional ","Void ", "Solar ")
	var/disaster_name2 = pick("storm","gate","distortion","disruption","implosion","vortex","portal","nova","supernova","collapse")
	disaster_name = disaster_name1 + disaster_name2

	var/contrived_excuse = pick("mandatory repairs","engine malfunction","emergency form 393-B","complete and all-consuming apathy","hazardous flight conditions","fuel rationing","the accidental purchase of a school bus in its place","wrathful wizards")

	if(derelict_mode)
		command_alert("[disaster_name] eve## de####ed on **e stat!on. **$00AA curren#_ unava!l4ble due t0 [contrived_excuse]. All per#############ERR","Haz4rD*## Ev##_ A**Rt")
		playsound_global(world, 'sound/machines/siren_generalquarters_quiet.ogg', 90)
		SPAWN(0.5 SECONDS)
			random_events.announce_events = 0
			random_events.force_event("Power Outage","Scripted Disaster Mode Event")

	else
		command_alert("[disaster_name] event detected on the station.  Unfortunately, the shuttle is currently unavailable due to [contrived_excuse]. All personnel must contain this event.", "Hazardous Event Alert")

	for(var/turf/T in world)
		if(prob(21) && T.z == 1 && istype(T,/turf/simulated/floor))
			SPAWN(50+rand(0,6250))
				var/obj/vortex/P = new /obj/vortex( T )
				P.name = disaster_name
				if(prob(6) && length(scarysounds))
					playsound_global(world, pick(scarysounds), 50)
		LAGCHECK(LAG_LOW)

	return

