/datum/random_event/minor/trader
	name = "Travelling Trader"
	//moved centcom headline and message down to the event_effect to change it depending on where the shuttle docks, preserving just in case, feel free to remove if you feel it's unnecessary
	//centcom_headline = "Commerce and Customs Alert"
	//centcom_message = "A merchant shuttle has docked with the station."
	var/active = FALSE
	var/map_turf = /turf/space //Set in event_effect() by map settings
	var/centcom_turf = /turf/unsimulated/outdoors/grass //Not currently modified

	/// Centcom area the shuttle comes from
	var/area/shuttle/merchant_shuttle/start_location = null
	/// Station area the shuttle goes to
	var/area/shuttle/merchant_shuttle/end_location = null

	event_effect()
		..()
		if(active)
			return //This is to prevent admins from fucking up the shuttle arrival/departures by spamming this event.
		active = TRUE
		map_turf = map_settings.shuttle_map_turf
#ifdef UNDERWATER_MAP // bodge fix for oshan
		var/shuttle = pick("left","right");
#else
		var/shuttle = pick("left","right","left","right","diner"); // just making the diner docking a little less common.
#endif
		var/docked_where = shuttle == "diner" ? "space diner" : "station";
		var/loc_string = ""
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
			loc_string = " [end_location.loc_string] shuttle dock"

		var/obj/npc/trader/random/trader_npc = locate() in start_location
		if (!trader_npc)
			CRASH("Trader NPC missing in [start_location.name] during trader random event. Guh?")
		command_alert("\An [pick(trader_npc.descriptions)] merchant shuttle will dock with the [docked_where][loc_string] shortly.", "Commerce and Customs Alert")
		signal_dock(shuttle, DOCK_EVENT_INCOMING)
		for(var/client/C in clients)
			if(C.mob && (C.mob.z == Z_LEVEL_STATION))
				C.mob.playsound_local(C.mob, 'sound/misc/announcement_chime.ogg', 30, 0)

		SPAWN(30 SECONDS)

			var/list/dest_turfs = src.arrive()
			signal_dock(shuttle, DOCK_EVENT_ARRIVED)

			SPAWN(rand(5 MINUTES, 10 MINUTES))
				command_alert("The merchant shuttle is preparing to undock, please stand clear.", "Merchant Departure Alert")

				signal_dock(shuttle, DOCK_EVENT_OUTGOING)
				sleep(30 SECONDS)

				src.depart(dest_turfs)
				signal_dock(shuttle, DOCK_EVENT_DEPARTED)
				active = FALSE

	proc/signal_dock(var/dock, var/event)
		switch(dock)
			if("diner")
				SEND_GLOBAL_SIGNAL(COMSIG_DOCK_TRADER_DINER, event)
			if("left")
				SEND_GLOBAL_SIGNAL(COMSIG_DOCK_TRADER_WEST, event)
			if("right")
				SEND_GLOBAL_SIGNAL(COMSIG_DOCK_TRADER_EAST, event)

	/// Get shuttle from centcom
	proc/arrive()
		var/list/dest_turfs = list()
		var/throwy = world.maxy

		for(var/atom/A as obj|mob in end_location)
			SPAWN(0)
				A.ex_act(1)

		for(var/turf/T in end_location)
			dest_turfs += T
			if(T.y < throwy)
				throwy = T.y

		// hey you, get out of the way!
		for(var/turf/T in dest_turfs)
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
				P.ReplaceWith(map_turf, FALSE, TRUE, FALSE, TRUE)

		end_location.color = null

		start_location.move_contents_to(end_location, centcom_turf, turf_to_skip=/turf/unsimulated/outdoors/grass, turftoleave=/turf/unsimulated/outdoors/grass)

		return dest_turfs

	/// Send shuttle to centcom
	proc/depart(var/list/dest_turfs)
		// hey you, get out of my shuttle! I ain't taking you back to centcom!
		for(var/turf/T in dest_turfs)
			for(var/mob/AM in T)
				if(isobserver(AM))
					continue
				showswirl(AM)
				AM.set_loc(pick_landmark(LANDMARK_LATEJOIN, locate(150, 150, 1)))
				showswirl(AM)
			for (var/obj/O in T)
				get_hiding_jerk(O)

		for (var/turf/O in end_location)
			if (istype(O, map_turf))
				O.ReplaceWith(centcom_turf, FALSE, TRUE, FALSE, TRUE)

		end_location.move_contents_to(start_location, map_turf, turf_to_skip=global.map_settings.shuttle_map_turf, turftoleave=global.map_settings.shuttle_map_turf)

		#ifdef UNDERWATER_MAP
		start_location.color = OCEAN_COLOR
		#endif

		station_repair.repair_turfs(dest_turfs, force_floor=TRUE)

/proc/get_hiding_jerk(var/atom/movable/container)
	for(var/atom/movable/AM in container)
		if(AM.contents.len) get_hiding_jerk(AM)
		if(ismob(AM))
			var/mob/M = AM
			boutput(AM, SPAN_ALERT("<b>Your body is destroyed as the merchant shuttle passes [pick("an eldritch decomposure field", "a life negation ward", "a telekinetic assimilation plant", "a swarm of matter devouring nanomachines", "an angry Greek god", "a burnt-out coder", "a death ray fired millenia ago from a galaxy far, far away")].</b>"))
			if(isliving(M))
				logTheThing(LOG_COMBAT, M, "was gibbed by trying to hide on a merchant shuttle.")
			M.gib()
