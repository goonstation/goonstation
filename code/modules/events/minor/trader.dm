/datum/random_event/minor/trader
	name = "Travelling Trader"
	//moved centcom headline and message down to the event_effect to change it depending on where the shuttle docks, preserving just in case, feel free to remove if you feel it's unnecessary
	//centcom_headline = "Commerce and Customs Alert"
	//centcom_message = "A merchant shuttle has docked with the station."
	var/active = 0
	var/map_turf = /turf/space //Set in event_effect() by map settings
	var/centcom_turf = /turf/unsimulated/outdoors/grass //Not currently modified

	event_effect()
		..()
		if(active == 1)
			return //This is to prevent admins from fucking up the shuttle arrival/departures by spamming this event.
		active = 1
		map_turf = map_settings.shuttle_map_turf
#ifdef UNDERWATER_MAP // bodge fix for oshan
		var/shuttle = pick("left","right");
#else
		var/shuttle = pick("left","right","left","right","diner"); // just making the diner docking a little less common.
#endif
		var/docked_where = shuttle == "diner" ? "space diner" : "station";
		command_alert("A merchant shuttle has docked with the [docked_where].", "Commerce and Customs Alert")
		var/area/start_location = null
		var/area/end_location = null
		if(shuttle == "diner")
			start_location = locate(/area/shuttle/merchant_shuttle/diner_centcom)
			end_location = locate(/area/shuttle/merchant_shuttle/diner_station)
		else
			if(shuttle == "left")
				start_location = locate(map_settings ? map_settings.merchant_left_centcom : /area/shuttle/merchant_shuttle/left_centcom)
				end_location = locate(map_settings ? map_settings.merchant_left_station : /area/shuttle/merchant_shuttle/left_station)
			else
				start_location = locate(map_settings ? map_settings.merchant_right_centcom : /area/shuttle/merchant_shuttle/right_centcom)
				end_location = locate(map_settings ? map_settings.merchant_right_station : /area/shuttle/merchant_shuttle/right_station)

		var/list/dstturfs = list()
		var/throwy = world.maxy

		for(var/atom/A as obj|mob in end_location)
			SPAWN_DBG(0)
				A.ex_act(1)

		for(var/turf/T in end_location)
			dstturfs += T
			if(T.y < throwy)
				throwy = T.y

		// hey you, get out of the way!
		for(var/turf/T in dstturfs)
			// find the turf to move things to
			var/turf/D = locate(T.x, throwy - 1, 1)
			//var/turf/E = get_step(D, SOUTH)
			for(var/atom/movable/AM as mob|obj in T)
				if(isobserver(AM))
					continue
				AM.Move(D)
			if(istype(T, /turf/simulated))
				qdel(T)

		for (var/turf/P in start_location)
			if (istype(P, centcom_turf))
				new map_turf(P)

		end_location.color = null

		start_location.move_contents_to(end_location, centcom_turf)

		sleep(rand(3000,6000))

		command_alert("The merchant shuttle is preparing to undock, please stand clear.", "Merchant Departure Alert")

		sleep(30 SECONDS)

		// hey you, get out of my shuttle! I ain't taking you back to centcom!
		var/area/teleport_to_location = locate(/area/station/crew_quarters/bar)
		for(var/turf/T in dstturfs)
			for(var/mob/AM in T)
				if(isobserver(AM))
					continue
				showswirl(AM)
				AM.set_loc(pick(get_area_turfs(teleport_to_location, 1)))
				showswirl(AM)
			for (var/obj/O in T)
				get_hiding_jerk(O)

		for (var/turf/O in end_location)
			if (istype(O, map_turf))
				new centcom_turf(O)

		end_location.move_contents_to(start_location, map_turf)

		#ifdef UNDERWATER_MAP
		start_location.color = OCEAN_COLOR
		#endif

		active = 0

/proc/get_hiding_jerk(var/atom/movable/container)
	for(var/atom/movable/AM in container)
		if(AM.contents.len) get_hiding_jerk(AM)
		if(ismob(AM))
			var/mob/M = AM
			boutput(AM, "<span class='alert'><b>Your body is destroyed as the merchant shuttle passes [pick("an eldritch decomposure field", "a life negation ward", "a telekinetic assimilation plant", "a swarm of matter devouring nanomachines", "an angry Greek god", "a burnt-out coder", "a death ray fired millenia ago from a galaxy far, far away")].</b></span>")
			M.gib()
