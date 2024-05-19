/datum/random_event/major/blowout
	name = "Radioactive Blowout"
	var/list/space_color = list(
		2,  2,  2,  0,
	   -2,  2,  2,  0,
		2, -2, -2,  0,
		0,  0,  0,  2,
		0,  0,  0,  0,
	)
#ifdef RP_MODE
	required_elapsed_round_time = 40 MINUTES
	weight = 50 //less events to choose from on RP and radstorms get annoying when there's 3 per shift
#else
	required_elapsed_round_time = 26.6 MINUTES
#endif
	event_effect()
		..()
		var/timetoreachsec = rand(1,9)
		var/timetoreach = rand(30,60)
		var/actualtime = timetoreach * 10 + timetoreachsec

		var/sound/siren = sound('sound/misc/airraid_loop_short.ogg')
		siren.repeat = TRUE
		siren.channel = 5
		siren.volume = 50 // wire note: lets not deafen players with an air raid siren
		world << siren
		command_alert("Extreme levels of radiation detected approaching the [station_or_ship()]. All personnel have [timetoreach].[timetoreachsec] seconds to enter a maintenance tunnel or radiation safezone. Maintenance doors have temporarily had their access requirements removed. This is not a test.", "Anomaly Alert", alert_origin = ALERT_WEATHER)

		SPAWN(0)
			var/list/obj/machinery/door/airlock/touched_airlocks = list()
			for_by_tcl(A, /obj/machinery/door/airlock)
				LAGCHECK(LAG_LOW)
				if (A.z != Z_LEVEL_STATION)
					continue
				if (!(istype(A, /obj/machinery/door/airlock/maintenance) || istype(A, /obj/machinery/door/airlock/pyro/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/glass/maintenance)))
					continue
				if (access_maint_tunnels in A.req_access)
					touched_airlocks[A] = A.req_access
					A.req_access = null

			sleep(actualtime)

			for (var/area/A in world)
				if (A.do_not_irradiate || (A.z != Z_LEVEL_STATION))
					continue

				if (!A.irradiated)
					A.irradiated = TRUE
					A.UpdateIcon()
				for (var/turf/T in A)
					if (rand(0,1000) < 5 && istype(T,/turf/simulated/floor))
						Artifact_Spawn(T)

				LAGCHECK(LAG_LOW) // let's only check after we've gone through a few areas

			siren.repeat = FALSE
			siren.channel = 5
			siren.volume = 50


	#ifndef UNDERWATER_MAP
			RECOLOUR_PARALLAX_RENDER_SOURCES_IN_GROUP(Z_LEVEL_STATION, src.space_color, 3 SECONDS)
			ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/blowout_clouds, 3 SECONDS)
			GET_PARALLAX_RENDER_SOURCE_FROM_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/blowout_clouds)?.scroll_angle = rand(0, 359)
	#endif

			world << siren

			sleep(0.4 SECONDS)

			blowout = TRUE

			var/sound/blowoutsound = sound('sound/misc/blowout.ogg')
			blowoutsound.repeat = 0
			blowoutsound.channel = 5
			blowoutsound.volume  = 20
			world << blowoutsound
			boutput(world, SPAN_ALERT("<B>WARNING</B>: Mass radiation has struck [station_name(1)]. Do not leave safety until all radiation alerts have been cleared."))

			for (var/mob/M in mobs)
				SPAWN(0)
					if (!inafterlife(M) && !isVRghost(M))
						shake_camera(M, 400, 6)

			sleep(randfloat(1.5 MINUTES,2 MINUTES)) // drsingh lowered these by popular request.
			command_alert("Radiation levels lowering [station_or_ship()]wide. ETA 60 seconds until all areas are safe.", "Anomaly Alert", alert_origin = ALERT_WEATHER)

			sleep(rand(25 SECONDS,50 SECONDS)) // drsingh lowered these by popular request

			for (var/area/A in world)
				LAGCHECK(LAG_LOW)
				if (A.z != Z_LEVEL_STATION)
					continue
				if (!A.permarads)
					A.irradiated = FALSE
				A.UpdateIcon()
			blowout = FALSE

			command_alert("All radiation alerts onboard [station_name(1)] have been cleared. You may now leave the tunnels freely. Maintenance doors will regain their normal access requirements shortly.", "All Clear", alert_origin = ALERT_WEATHER)

	#ifndef UNDERWATER_MAP
			RECOLOUR_PARALLAX_RENDER_SOURCES_IN_GROUP(Z_LEVEL_STATION, list(), 3 SECONDS)
			REMOVE_PARALLAX_RENDER_SOURCE_FROM_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/blowout_clouds, 3 SECONDS)
	#endif

			sleep(rand(25 SECONDS,50 SECONDS))

			for (var/obj/machinery/door/airlock/A as anything in touched_airlocks)
				A.req_access = touched_airlocks[A]
