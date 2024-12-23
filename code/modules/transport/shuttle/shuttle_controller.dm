/// Controls the emergency shuttle
var/global/datum/shuttle_controller/emergency_shuttle/emergency_shuttle

/datum/shuttle_controller
	var/location = SHUTTLE_LOC_CENTCOM //! 0 = somewhere far away, 1 = at SS13, 2 = returned from SS13.
	var/online = FALSE
	var/direction = SHUTTLE_DIRECTION_TO_STATION //! -1 = going back to central command, 1 = going back to SS13
	var/disabled = SHUTTLE_CALL_ENABLED //! Block shuttle calling if it's disabled.
	var/callcount = 0 //! Number of shuttle calls required to break through interference (wizard mode)
	var/endtime			//! round_elapsed_ticks		that shuttle arrives
	var/announcement_done = SHUTTLE_ANNOUNCEMENT_ZERO	//! the stages of the shuttle prepping for transit
	var/can_recall = TRUE //! set to FALSE in the admin call thing to make it not recallable
	var/list/airbridges = list()
	var/map_turf = /turf/space //! Set in New() by map settings
	var/transit_turf = /turf/space/no_replace //! Not currently modified
	var/centcom_turf = /turf/unsimulated/floor/shuttlebay //! Not currently modified
	var/turf/sound_turf = null //! where to play takeoff sounds, defined by landmark

	/// call the shuttle
	/// if not called before, set the endtime to T+600 seconds
	/// otherwise if outgoing, switch to incoming
	proc/incall()
		if (emergency_shuttle.disabled == SHUTTLE_CALL_FULLY_DISABLED)
			message_admins("The shuttle would have been called now, but it has been fully disabled!")
			return FALSE

		if (!src.online || src.direction != SHUTTLE_DIRECTION_TO_CENTCOMM)
			playsound_global(world, 'sound/misc/shuttle_enroute.ogg', 100)

		if (src.online)
			if(src.direction == SHUTTLE_DIRECTION_TO_CENTCOMM)
				setdirection(SHUTTLE_DIRECTION_TO_STATION)
		else
			settimeleft(SHUTTLEARRIVETIME)
			src.online = TRUE

		INVOKE_ASYNC(ircbot, TYPE_PROC_REF(/datum/ircbot, event), "shuttlecall", src.timeleft())

		return TRUE

	proc/recall()
		if (src.online && src.direction == SHUTTLE_DIRECTION_TO_STATION)
			playsound_global(world, 'sound/misc/shuttle_recalled.ogg', 100)
			setdirection(SHUTTLE_DIRECTION_TO_CENTCOMM)
			ircbot.event("shuttlerecall", src.timeleft())


	/// returns the time (in seconds) before shuttle arrival
	/// note if direction = SHUTTLE_DIRECTION_TO_CENTCOMM, gives a count-up to SHUTTLEARRIVETIME
	proc/timeleft()
		if(src.online)
			var/timeleft = round((src.endtime - ticker.round_elapsed_ticks)/10 ,1)
			if(src.direction == SHUTTLE_DIRECTION_TO_STATION)
				return timeleft
			else
				return SHUTTLEARRIVETIME - timeleft
		else
			return SHUTTLEARRIVETIME

	/// sets the time left to a given delay (in seconds)
	proc/settimeleft(var/delay)
		src.endtime = ticker.round_elapsed_ticks + delay SECONDS

	/// sets the shuttle direction
	/// 1 = towards SS13, -1 = back to centcom. Uses defines like SHUTTLE_DIRECTION_TO_STATION
	proc/setdirection(var/dirn)
		if(src.direction == dirn)
			return
		src.direction = dirn
		// if changing direction, flip the timeleft by SHUTTLEARRIVETIME
		var/ticksleft = src.endtime - ticker.round_elapsed_ticks
		src.endtime = ticker.round_elapsed_ticks + (SHUTTLEARRIVETIME SECONDS - ticksleft)
		return

	proc/process()

	emergency_shuttle

		New()
			..()
			for_by_tcl(S, /obj/machinery/computer/airbr)
				if (S.emergency && !(S in src.airbridges))
					src.airbridges += S
			src.map_turf = map_settings.shuttle_map_turf
			src.sound_turf = pick_landmark(LANDMARK_SHUTTLE_SOUND)
			if (!istype(src.sound_turf))
				logTheThing(LOG_DEBUG, null, "Shuttle sound landmark not found, trying station shuttle area turfs")
				var/area/start_location = locate(map_settings ? map_settings.escape_station : /area/shuttle/escape/station)
				for (var/turf/new_target in start_location)
					if(istype(new_target))
						src.sound_turf = new_target
						break
		process()
			if (!src.online)
				return
			var/timeleft = src.timeleft()
			if (timeleft > 1e5 || timeleft <= 0)		// midnight rollover protection
				timeleft = 0
			switch (src.location)
				if (SHUTTLE_LOC_CENTCOM)
					if (timeleft > SHUTTLEARRIVETIME)
						src.online = FALSE
						src.direction = SHUTTLE_DIRECTION_TO_STATION
						src.endtime = null
						return FALSE

					else if (timeleft <= 0)
						src.location = SHUTTLE_LOC_STATION
						if (ticker?.mode)
							if (ticker.mode.shuttle_available == SHUTTLE_AVAILABLE_DISABLED)
								command_alert("CentCom has received reports of unusual activity on the station. The shuttle has been returned to base as a precaution, and will not be usable.");
								src.online = FALSE
								src.direction = SHUTTLE_DIRECTION_TO_STATION
								src.endtime = null
								return FALSE
							if (ticker.mode.shuttle_available == SHUTTLE_AVAILABLE_DELAY && (ticker.round_elapsed_ticks < max(0, ticker.mode.shuttle_available_threshold)) && callcount < 1)
								src.callcount++
								command_alert("CentCom reports that the emergency shuttle has veered off course due to unknown interference. The next shuttle will be equipped with electronic countermeasures to break through.");
								src.online = FALSE
								src.direction = SHUTTLE_DIRECTION_TO_STATION
								src.location = SHUTTLE_LOC_CENTCOM
								src.endtime = null
								return FALSE

						processScheduler.disableProcess("Fluid_Turfs")

						var/area/start_location = locate(map_settings ? map_settings.escape_centcom : /area/shuttle/escape/centcom)
						var/area/end_location = locate(map_settings ? map_settings.escape_station : /area/shuttle/escape/station)

						var/list/dstturfs = list()
						var/northBound = 1
						var/southBound = world.maxy
						var/westBound = world.maxx
						var/eastBound = 1

						// explode everything that exists where the shuttle is landing
						for (var/atom/A as obj|mob in end_location)
							SPAWN(0)
								if (isliving(A) && !isintangible(A))
									var/mob/living/M = A
									M.unlock_medal("Reserved Parking", TRUE)
								A.ex_act(1)

						end_location.color = null //Remove the colored shuttle!

						for (var/turf/T in end_location)
							dstturfs += T
							if (T.y > northBound)
								northBound = T.y
							if (T.y < southBound)
								southBound = T.y
							if (T.x < westBound)
								westBound = T.x
							if (T.x > eastBound)
								eastBound = T.x

						// hey you, get out of the way!
						var/shuttle_dir = map_settings ? map_settings.escape_dir : SOUTH
						for (var/turf/T in dstturfs)
							// find the turf to move things to
							var/turf/D = locate(shuttle_dir == EAST ? eastBound + 1 : T.x, // X
												shuttle_dir == NORTH ? northBound + 1 : shuttle_dir == EAST ? T.y : southBound - 1, // Y
												1) // Z
							for (var/atom/movable/AM as mob|obj in T)
								if (isobserver(AM))
									continue // skip ghosties
								if (istype(AM, /obj/overlay/tile_effect))
									continue
								if (istype(AM, /obj/effects/precipitation))
									continue
								AM.set_loc(D)
								// NOTE: Commenting this out to avoid recreating mass driver glitch
								/*
								SPAWN(0)
									AM.throw_at(E, 1, 1)
									return
								*/

						var/filler_turf = text2path(start_location.filler_turf)
						if (!filler_turf)
							filler_turf = centcom_turf
						start_location.move_contents_to(end_location, filler_turf, turf_to_skip=/turf/unsimulated/floor/shuttlebay)
						for (var/turf/P in end_location)
							if (istype(P, filler_turf))
								P.ReplaceWith(src.map_turf, keep_old_material = 0, force = 1)


						settimeleft(SHUTTLELEAVETIME)

						if (src.airbridges.len)
							for (var/obj/machinery/computer/airbr/S in src.airbridges)
								S.establish_bridge()

						boutput(world, "<B>The Emergency Shuttle has docked with the station! You have [src.timeleft()/60] minutes to board the Emergency Shuttle.</B>")
						ircbot.event("shuttledock")
						playsound_global(world, 'sound/misc/shuttle_arrive1.ogg', 100)

						processScheduler.enableProcess("Fluid_Turfs")

						return TRUE

#ifdef SHUTTLE_TRANSIT // shuttle spends some time in transit to centcom before arriving
				if (SHUTTLE_LOC_STATION)
					if (!src.announcement_done && timeleft <= 60)
						var/display_time = round(src.timeleft()/60)
						//if (display_time <= 0) // The Emergency Shuttle will be entering the wormhole to CentCom in 0 minutes!
							//display_time = 1 // fuckofffffffffff
						boutput(world, "<B>The Emergency Shuttle will be entering the Channel in [display_time] minute[s_es(display_time)]! Please prepare for Channel traversal.</B>")
						src.announcement_done = SHUTTLE_ANNOUNCEMENT_WILL_DEPART_IN

					else if (src.announcement_done < SHUTTLE_ANNOUNCEMENT_SHIP_CHARGE && timeleft < 30)
						if (istype(src.sound_turf))
							playsound(src.sound_turf, 'sound/effects/ship_charge.ogg', 100)
						src.announcement_done = SHUTTLE_ANNOUNCEMENT_SHIP_CHARGE

					else if (src.announcement_done < SHUTTLE_ANNOUNCEMENT_SHIP_ENGAGE && timeleft < 4)
						if (istype(src.sound_turf))
							playsound(src.sound_turf, 'sound/effects/ship_engage.ogg', 100)
						src.announcement_done = SHUTTLE_ANNOUNCEMENT_SHIP_ENGAGE

					else if (src.announcement_done < SHUTTLE_ANNOUNCEMENT_SHIP_IGNITION && timeleft < 1)
						if (istype(src.sound_turf))
							playsound(src.sound_turf, 'sound/effects/explosion_new4.ogg', 75)
							playsound(src.sound_turf, 'sound/effects/flameswoosh.ogg', 75)
						src.announcement_done = SHUTTLE_ANNOUNCEMENT_SHIP_IGNITION
						if (src.airbridges.len)
							for (var/obj/machinery/computer/airbr/S in src.airbridges)
								S.remove_bridge()

					else if (timeleft > 0)
						return FALSE

					else
						src.location = SHUTTLE_LOC_TRANSIT
						var/area/start_location = locate(map_settings ? map_settings.escape_station : /area/shuttle/escape/station)
						var/area/end_location = locate(map_settings ? map_settings.escape_transit : /area/shuttle/escape/transit)

						var/door_type = map_settings ? map_settings.ext_airlocks : /obj/machinery/door/airlock/external
						for (var/obj/machinery/door/D in start_location)
							if (istype(D, door_type))
								D.set_density(1)
								D.locked = 1
								D.UpdateIcon()

						for (var/atom/A in start_location)
							if(istype(A, /obj/stool))
								var/obj/stool/O = A
								if(!O.anchored)
									var/atom/target = get_edge_target_turf(O, pick(alldirs))
									if(O.buckled_guy)
										boutput(O.buckled_guy, SPAN_ALERT("The [O] shoots off due to being unsecured!"))
										O.unbuckle()
									if(target)
										O.throw_at(target, 25, 1) //dear god I am sorry in advance for doing this
							else if(istype(A, /mob))
								var/mob/M = A
								shake_camera(M, 32, 32)
								if (!isturf(M.loc) || !isliving(M) || isintangible(M))
									continue
								SPAWN(1 DECI SECOND)
									var/bonus_stun = 0
									if (ishuman(M))
										var/mob/living/carbon/human/H = M
										bonus_stun = (H?.buckled && H.on_chair)
										//DEBUG_MESSAGE("[M] is human and bonus_stun is [bonus_stun]")
									if (!M.buckled || bonus_stun)
										M.changeStatus("stunned", 2 SECONDS)
										M.changeStatus("knockdown", 2 SECONDS)

										if (prob(50) || bonus_stun)
											var/atom/target = get_edge_target_turf(M, pick(alldirs))
											if (target)
												if (M.buckled) M.buckled.unbuckle()
												M.throw_at(target, 25, 1)
												if (bonus_stun)
													M.changeStatus("unconscious", 6 SECONDS)
													M.playsound_local(target, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
													M.show_text("You are thrown off the chair! [prob(50) ? "Standing on that during takeoff was a terrible idea!" : null]", "red")

										if (!bonus_stun)
											M.show_text("You are thrown about as the shuttle launches due to not being securely buckled in!", "red")

						var/area/shuttle_particle_spawn/particle_spawn = locate(/area/shuttle_particle_spawn) in world
						if (particle_spawn)
							particle_spawn.start_particles()

						DEBUG_MESSAGE("Now moving shuttle!")
						start_location.move_contents_to(end_location, map_turf, turf_to_skip = list(/turf/simulated/floor/plating, src.map_turf))

						if(station_repair.station_generator)
							var/list/turf/turfs_to_fix = get_area_turfs(start_location)
							if(length(turfs_to_fix))
								station_repair.repair_turfs(turfs_to_fix, force_floor=TRUE)

						DEBUG_MESSAGE("Done moving shuttle!")
						settimeleft(SHUTTLETRANSITTIME)
						boutput(world, "<B>The Emergency Shuttle has left for CentCom! It will arrive in [src.timeleft() / 60] minute[s_es(src.timeleft() / 60)]!</B>")
						playsound_global(world, 'sound/misc/shuttle_enroute.ogg', 100)
						//online = 0

						return TRUE

				if (SHUTTLE_LOC_TRANSIT)
					if (timeleft > 0)
						return FALSE
					else
						var/area/start_location = locate(map_settings ? map_settings.escape_transit : /area/shuttle/escape/transit)
						var/area/end_location = locate(map_settings ? map_settings.escape_centcom : /area/shuttle/escape/centcom)

						for (var/mob/M in start_location)
							M.removeOverlayComposition(/datum/overlayComposition/shuttle_warp)
							M.removeOverlayComposition(/datum/overlayComposition/shuttle_warp/ew)

						var/door_type = map_settings ? map_settings.ext_airlocks : /obj/machinery/door/airlock/external
						for (var/obj/machinery/door/D in start_location)
							if (istype(D, door_type))
								D.set_density(0)
								D.locked = 0
								D.UpdateIcon()

						var/filler_turf = text2path(end_location.filler_turf)
						if (!filler_turf)
							filler_turf = centcom_turf
						start_location.move_contents_to(end_location, src.transit_turf, turf_to_skip=/turf/space)
						for (var/turf/G in end_location)
							if (istype(G, src.transit_turf))
								G.ReplaceWith(filler_turf, keep_old_material = 0, force = 1)
						boutput(world, "<BR><B>The Emergency Shuttle has arrived at CentCom!")
						playsound_global(world, 'sound/misc/shuttle_centcom.ogg', 100)
						logTheThing(LOG_STATION, null, "The emergency shuttle has arrived at Centcom.")
						src.online = FALSE

						src.location = SHUTTLE_LOC_RETURNED
						return TRUE
				else
					return TRUE

#else // standard shuttle departure - immediately arrives at centcom
				if (SHUTTLE_LOC_STATION)
					if (timeleft > 0)
						return FALSE
					else
						src.location = SHUTTLE_LOC_RETURNED
						var/area/start_location = locate(map_settings ? map_settings.escape_station : /area/shuttle/escape/station)
						var/area/end_location = locate(map_settings ? map_settings.escape_centcom : /area/shuttle/escape/centcom)

						start_location.move_contents_to(end_location, map_turf)
						for (var/turf/O in end_location)
							if (istype(O, transit_turf))
								O.ReplaceWith(centcom_turf, keep_old_material = 0, force = 1)
						boutput(world, "<BR><B>The Emergency Shuttle has arrived at CentCom!")
						logTheThing(LOG_STATION, null, "The emergency shuttle has arrived at Centcom.")
						src.online = FALSE
						return TRUE
				else
					return TRUE
#endif
