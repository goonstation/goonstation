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
	var/list/candidates = list()
	for(var/mob/new_player/player in mobs)
		if (ishellbanned(player))
			continue
		if (player.client && player.ready && !candidates.Find(player.mind) && player.client.preferences.be_wraith)
			candidates += player.mind
	if (candidates.len == 0)
		return 0
	var/datum/mind/twraith = pick(candidates) // Just one for now
	twraith.special_role = "wraith"
	Agimmicks += twraith

	return 1

/datum/game_mode/disaster/announce()
	if(derelict_mode)
		boutput(world, "<tt>BUG: MEM ERR 0000FF88 00F90045</tt>")
		world << sound('sound/machines/glitch1.ogg')
		boutput(world, "<B>We are experiencing technical difficulties. Please remain calm. Help is on the way.</B>")
		boutput(world, "<B>Report to your station's emergency rally point: CHAPEL.</B>")
	else
		boutput(world, "<B>The current game mode is - Disaster!</B>")
		boutput(world, "<B>The station is in the middle of a cosmic disaster! You must escape or at least live!</B>")


/datum/game_mode/disaster/post_setup()

//	boutput(world, "disaster loaded :I")
	for(var/datum/mind/wraith in Agimmicks)
		var/wraith_spawn = observer_start.len ? pick(observer_start) : locate(150, 150, 1)
		wraith.current.set_loc(wraith_spawn)
		generate_wraith_objectives(wraith)

	emergency_shuttle.disabled = 1 //Disable the shuttle temporarily.

	if(derelict_mode)
		SPAWN_DBG(1 SECOND)
			var/list/CORPSES = list()
			var/list/JUNK = list()
			JUNK = halloweenspawn.Copy()
			for(var/obj/landmark/S in landmarks)//world)
				if (S.name == "peststart")
					CORPSES.Add(S.loc)
				LAGCHECK(LAG_LOW)
			if(CORPSES.len)
				for(var/turf/T in CORPSES)
					var/obj/decal/skeleton/S = new/obj/decal/skeleton(T)
					S.name = "corpse"
					S.desc = "The mangled body of some poor [pick("chump","sap","chap","crewmember","jerk","dude","lady","idiot","employee","oaf")]."
					S.icon = 'icons/misc/hstation.dmi'
					S.icon_state = pick("body3","body4","body5","body6","body7","body8","clowncorpse")
			if(JUNK.len)
				for(var/turf/T in JUNK)
					var/junk_type = rand(1,4)
					switch(junk_type)
						if(1)
							new/obj/candle_light(T)
						if(2)
							new/obj/spook(T)
						if(3)
							new/obj/critter/floateye(T)
						if(4)
							var/obj/item/device/light/glowstick/G = new/obj/item/device/light/glowstick(T)
							SPAWN_DBG(2 SECONDS)
								G.on = 1
								G.icon_state = "glowstick-on"
								G.light.enable()

	var/start_wait = rand(waittime_l, waittime_h)

	SPAWN_DBG (start_wait)
		start_disaster()
//
	SPAWN_DBG (start_wait + shuttle_waittime)
		emergency_shuttle.disabled = 0
		emergency_shuttle.incall()
		if(derelict_mode)
			command_alert("Ev4C**!on shu9999999__ called. Prepare fo# evacua ****SIGNAL LOST****","Emergency Al&RT")
			world << sound('sound/machines/engine_alert2.ogg')
		else
			command_alert("The shuttle has been called.","Emergency Shuttle Update")

	if(derelict_mode) // ready up some effects and noises
		SPAWN_DBG(0.2 SECONDS)
			for(var/mob/living/carbon/human/H in mobs)
				H.flash(3 SECONDS)

		SPAWN_DBG(10 SECONDS)
			world << sound('sound/effects/creaking_metal1.ogg')
			for(var/mob/living/carbon/human/H in mobs)
				shake_camera(H, 8, 3)
				H.change_misstep_chance(5)

		SPAWN_DBG(20 SECONDS)
			if(scarysounds && scarysounds.len)
				world << sound(pick(scarysounds))

		SPAWN_DBG(30 SECONDS)
			if(scarysounds && scarysounds.len)
				world << sound(pick(scarysounds))

		SPAWN_DBG(40 SECONDS)
			world << sound('sound/effects/creaking_metal1.ogg')
			for(var/mob/living/carbon/human/H in mobs)
				shake_camera(H, 8, 2)
				H.change_misstep_chance(5)

		SPAWN_DBG(1 MINUTE)
			world << sound('sound/effects/creaking_metal1.ogg')
			for(var/mob/living/carbon/human/H in mobs)
				shake_camera(H, 7, 1)
				H.change_misstep_chance(5)

		SPAWN_DBG(80 SECONDS)
			if(scarysounds && scarysounds.len)
				world << sound(pick(scarysounds))

	return

/datum/game_mode/disaster/declare_completion()
	var/list/survivors = list()
	var/area/escape_zone = locate(map_settings.escape_centcom)

	for(var/mob/living/player in mobs)
		if (player.client)
			if (!isdead(player))
				var/turf/location = get_turf(player.loc)
				if (location in escape_zone)
					survivors[player.real_name] = "shuttle"
					player.unlock_medal("Icarus", 1)
				else
					survivors[player.real_name] = "alive"

	if (survivors.len)
		boutput(world, "<span style=\"color:blue\"><B>The following survived the [disaster_name] event!</B></span>")
		for(var/survivor in survivors)
			var/condition = survivors[survivor]
			switch(condition)
				if("shuttle")
					boutput(world, "&emsp; <B><FONT size = 2>[survivor] escaped on the shuttle!</FONT></B>")
				if("alive")
					boutput(world, "&emsp; <FONT size = 1>[survivor] stayed alive. Whereabouts unknown.</FONT>")

	else
		boutput(world, "<span style=\"color:blue\"><B>No one survived the [disaster_name] event!</B></span>")

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
		world << sound('sound/machines/siren_generalquarters_quiet.ogg')
		SPAWN_DBG(0.5 SECONDS)
			random_events.announce_events = 0
			random_events.force_event("Power Outage","Scripted Disaster Mode Event")

	else
		command_alert("[disaster_name] event detected on the station.  Unfortunately, the shuttle is currently unavailable due to [contrived_excuse]. All personnel must contain this event.", "Hazardous Event Alert")

	for(var/turf/T in world)
		if(prob(21) && T.z == 1 && istype(T,/turf/simulated/floor))
			SPAWN_DBG(50+rand(0,6250))
				var/obj/vortex/P = new /obj/vortex( T )
				P.name = disaster_name
				if(prob(6) && scarysounds && scarysounds.len)
					world << sound(pick(scarysounds))
		LAGCHECK(LAG_LOW)

	return

