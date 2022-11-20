// Controls the emergency shuttle
var/global/datum/shuttle_controller/emergency_shuttle/emergency_shuttle

datum/shuttle_controller
	var/location = 0 //0 = somewhere far away, 1 = at SS13, 2 = returned from SS13
	var/online = 0
	var/direction = 1 //-1 = going back to central command, 1 = going back to SS13
	var/disabled = 0 //Block shuttle calling if it's disabled.
	var/callcount = 0 //Number of shuttle calls required to break through interference (wizard mode)
	var/endtime			// round_elapsed_ticks		that shuttle arrives
	var/announcement_done = 0
	var/can_recall = 1 // set to 0 in the admin call thing to make it not recallable
	var/list/airbridges = list()
	var/map_turf = /turf/space //Set in New() by map settings
	var/transit_turf = /turf/space/no_replace //Not currently modified
	var/centcom_turf = /turf/unsimulated/floor/shuttlebay //Not currently modified


	// call the shuttle
	// if not called before, set the endtime to T+600 seconds
	// otherwise if outgoing, switch to incoming
	proc/incall()
		if (emergency_shuttle.disabled == SHUTTLE_CALL_FULLY_DISABLED)
			message_admins("The shuttle would have been called now, but it has been fully disabled!")
			return FALSE

		if (!online || direction != 1)
			playsound_global(world, 'sound/misc/shuttle_enroute.ogg', 100)

		if (online)
			if(direction == -1)
				setdirection(1)
		else
			settimeleft(SHUTTLEARRIVETIME)
			online = 1

		INVOKE_ASYNC(ircbot, /datum/ircbot.proc/event, "shuttlecall", src.timeleft())

		return TRUE

	proc/recall()
		if (online && direction == 1)
			playsound_global(world, 'sound/misc/shuttle_recalled.ogg', 100)
			setdirection(-1)
			ircbot.event("shuttlerecall", src.timeleft())


	// returns the time (in seconds) before shuttle arrival
	// note if direction = -1, gives a count-up to SHUTTLEARRIVETIME
	proc/timeleft()
		if(online)
			var/timeleft = round((endtime - ticker.round_elapsed_ticks)/10 ,1)
			if(direction == 1)
				return timeleft
			else
				return SHUTTLEARRIVETIME-timeleft
		else
			return SHUTTLEARRIVETIME

	// sets the time left to a given delay (in seconds)
	proc/settimeleft(var/delay)
		endtime = ticker.round_elapsed_ticks + delay * 10

	// sets the shuttle direction
	// 1 = towards SS13, -1 = back to centcom
	proc/setdirection(var/dirn)
		if(direction == dirn)
			return
		direction = dirn
		// if changing direction, flip the timeleft by SHUTTLEARRIVETIME
		var/ticksleft = endtime - ticker.round_elapsed_ticks
		endtime = ticker.round_elapsed_ticks + (SHUTTLEARRIVETIME*10 - ticksleft)
		return

	proc/process()

	emergency_shuttle

		New()
			..()
			for_by_tcl(S, /obj/machinery/computer/airbr)
				if (S.emergency && !(S in src.airbridges))
					src.airbridges += S
			map_turf = map_settings.shuttle_map_turf

		process()
			if (!online)
				return
			var/timeleft = timeleft()
			if (timeleft > 1e5 || timeleft <= 0)		// midnight rollover protection
				timeleft = 0
			switch (location)
				if (SHUTTLE_LOC_CENTCOM)
					if (timeleft>SHUTTLEARRIVETIME)
						online = 0
						direction = 1
						endtime = null
						return 0

					else if (timeleft <= 0)
						location = SHUTTLE_LOC_STATION
						if (ticker?.mode)
							if (ticker.mode.shuttle_available == 0)
								command_alert("CentCom has received reports of unusual activity on the station. The shuttle has been returned to base as a precaution, and will not be usable.");
								online = 0
								direction = 1
								endtime = null
								return 0
							if (ticker.mode.shuttle_available == 2 && (ticker.round_elapsed_ticks < max(0, ticker.mode.shuttle_available_threshold)) && callcount < 1)
								callcount++
								command_alert("CentCom reports that the emergency shuttle has veered off course due to unknown interference. The next shuttle will be equipped with electronic countermeasures to break through.");
								online = 0
								direction = 1
								location = SHUTTLE_LOC_CENTCOM
								endtime = null
								return 0

						processScheduler.disableProcess("Fluid_Turfs")

						var/area/start_location = locate(map_settings ? map_settings.escape_centcom : /area/shuttle/escape/centcom)
						var/area/end_location = locate(map_settings ? map_settings.escape_station : /area/shuttle/escape/station)

						var/list/dstturfs = list()
						var/northBound = 1
						var/southBound = world.maxy
						var/westBound = world.maxx
						var/eastBound = 1

						for (var/atom/A as obj|mob in end_location)
							SPAWN(0)
								A.ex_act(1)

						end_location.color = null //Remove the colored shuttle!

						for (var/turf/T in end_location)
							dstturfs += T
							if (T.y > northBound) northBound = T.y
							if (T.y < southBound) southBound = T.y
							if (T.x < westBound) westBound = T.x
							if (T.x > eastBound) eastBound = T.x

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
								P.ReplaceWith(map_turf, keep_old_material = 0, force=1)


						settimeleft(SHUTTLELEAVETIME)

						if (src.airbridges.len)
							for (var/obj/machinery/computer/airbr/S in src.airbridges)
								S.establish_bridge()

						boutput(world, "<B>The Emergency Shuttle has docked with the station! You have [timeleft()/60] minutes to board the Emergency Shuttle.</B>")
						ircbot.event("shuttledock")
						playsound_global(world, 'sound/misc/shuttle_arrive1.ogg', 100)

						processScheduler.enableProcess("Fluid_Turfs")

						return 1

#ifdef SHUTTLE_TRANSIT // shuttle spends some time in transit to centcom before arriving
				if (SHUTTLE_LOC_STATION)
					if (!announcement_done && timeleft <= 60)
						var/display_time = round(timeleft()/60)
						//if (display_time <= 0) // The Emergency Shuttle will be entering the wormhole to CentCom in 0 minutes!
							//display_time = 1 // fuckofffffffffff
						boutput(world, "<B>The Emergency Shuttle will be entering the wormhole to CentCom in [display_time] minute[s_es(display_time)]! Please prepare for wormhole traversal.</B>")
						announcement_done = 1

					else if (announcement_done < 2 && timeleft < 30)
						var/area/sound_location = locate(/area/shuttle_sound_spawn)
						playsound(sound_location, 'sound/effects/ship_charge.ogg', 100)
						announcement_done = 2

					else if (announcement_done < 3 && timeleft < 4)
						var/area/sound_location = locate(/area/shuttle_sound_spawn)
						playsound(sound_location, 'sound/effects/ship_engage.ogg', 100)
						announcement_done = 3

					else if (announcement_done < 4 && timeleft < 1)
						var/area/sound_location = locate(/area/shuttle_sound_spawn)
						playsound(sound_location, 'sound/effects/explosion_new4.ogg', 75)
						playsound(sound_location, 'sound/effects/flameswoosh.ogg', 75)
						announcement_done = 4
						if (src.airbridges.len)
							for (var/obj/machinery/computer/airbr/S in src.airbridges)
								S.remove_bridge()

					else if (timeleft > 0)
						return 0

					else
						location = SHUTTLE_LOC_TRANSIT
						var/area/start_location = locate(map_settings ? map_settings.escape_station : /area/shuttle/escape/station)
						var/area/end_location = locate(map_settings ? map_settings.escape_transit : /area/shuttle/escape/transit)

						var/door_type = map_settings ? map_settings.ext_airlocks : /obj/machinery/door/airlock/external
						for (var/obj/machinery/door/D in start_location)
							if (istype(D, door_type))
								D.set_density(1)
								D.locked = 1
								D.UpdateIcon()

						for (var/atom/A in start_location)
							if(istype( A, /obj/stool ))
								var/obj/stool/O = A
								if( !O.anchored )
									var/atom/target = get_edge_target_turf(O, pick(alldirs))
									if( O.buckled_guy )
										boutput( O.buckled_guy, "<span class='alert'>The [O] shoots off due to being unsecured!</span>" )
										O.unbuckle()
									if( target )
										O.throw_at( target, 25, 1 )//dear god I am sorry in advance for doing this
							else if(istype( A, /mob ))
								var/mob/M = A
								shake_camera(M, 32, 32)
								M.addOverlayComposition(/datum/overlayComposition/shuttle_warp)
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
										M.changeStatus("weakened", 2 SECONDS)

										if (prob(50) || bonus_stun)
											var/atom/target = get_edge_target_turf(M, pick(alldirs))
											if (target)
												if (M.buckled) M.buckled.unbuckle()
												M.throw_at(target, 25, 1)
												if (bonus_stun)
													M.changeStatus("paralysis", 6 SECONDS)
													M.playsound_local(target, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
													M.show_text("You are thrown off the chair! [prob(50) ? "Standing on that during takeoff was a terrible idea!" : null]", "red")

										if (!bonus_stun)
											M.show_text("You are thrown about as the shuttle launches due to not being securely buckled in!", "red")

						var/area/shuttle_particle_spawn/particle_spawn = locate(/area/shuttle_particle_spawn) in world
						if (particle_spawn)
							particle_spawn.start_particles()

						DEBUG_MESSAGE("Now moving shuttle!")
						start_location.move_contents_to(end_location, map_turf, turf_to_skip=list(/turf/simulated/floor/plating, src.map_turf))

						if(station_repair.station_generator)
							var/list/turf/turfs_to_fix = get_area_turfs(start_location)
							if(length(turfs_to_fix))
								station_repair.repair_turfs(turfs_to_fix)

						DEBUG_MESSAGE("Done moving shuttle!")
						settimeleft(SHUTTLETRANSITTIME)
						boutput(world, "<B>The Emergency Shuttle has left for CentCom! It will arrive in [timeleft()/60] minute[s_es(timeleft()/60)]!</B>")
						playsound_global(world, 'sound/misc/shuttle_enroute.ogg', 100)
						//online = 0

						return 1

				if (SHUTTLE_LOC_TRANSIT)
					if (timeleft>0)
						return 0
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
						start_location.move_contents_to(end_location, transit_turf, turf_to_skip=/turf/space)
						for (var/turf/G in end_location)
							if (istype(G, transit_turf))
								G.ReplaceWith(filler_turf, keep_old_material = 0, force=1)
						boutput(world, "<BR><B>The Emergency Shuttle has arrived at CentCom!")
						playsound_global(world, 'sound/misc/shuttle_centcom.ogg', 100)
						logTheThing(LOG_STATION, null, "The emergency shuttle has arrived at Centcom.")
						online = 0

						location = SHUTTLE_LOC_RETURNED
						return 1
				else
					return 1

#else // standard shuttle departure - immediately arrives at centcom
				if (SHUTTLE_LOC_STATION)
					if (timeleft>0)
						return 0
					else
						location = SHUTTLE_LOC_RETURNED
						var/area/start_location = locate(map_settings ? map_settings.escape_station : /area/shuttle/escape/station)
						var/area/end_location = locate(map_settings ? map_settings.escape_centcom : /area/shuttle/escape/centcom)

						start_location.move_contents_to(end_location, map_turf)
						for (var/turf/O in end_location)
							if (istype(O, transit_turf))
								O.ReplaceWith(centcom_turf, keep_old_material = 0, force=1)
						boutput(world, "<BR><B>The Emergency Shuttle has arrived at CentCom!")
						logTheThing(LOG_STATION, null, "The emergency shuttle has arrived at Centcom.")
						online = 0
						return 1
				else
					return 1
#endif
