/datum/random_event/major/blowout
	name = "Radioactive Blowout"
	required_elapsed_round_time = 40 MINUTES
	var/space_color = "#ff4646"

	event_effect()
		..()
		var/timetoreachsec = rand(1,9)
		var/timetoreach = rand(30,60)
		var/actualtime = timetoreach * 10 + timetoreachsec

		for (var/mob/M in mobs)
			M.flash(3 SECONDS)
		var/sound/siren = sound('sound/misc/airraid_loop_short.ogg')
		siren.repeat = TRUE
		siren.channel = 5
		siren.volume = 50 // wire note: lets not deafen players with an air raid siren
		world << siren
		command_alert("Extreme levels of radiation detected approaching the [station_or_ship()]. All personnel have [timetoreach].[timetoreachsec] seconds to enter a maintenance tunnel or radiation safezone. Maintenance doors have temporarily had their access requirements removed. This is not a test.", "Anomaly Alert")

		SPAWN_DBG(0)
			for_by_tcl(A, /obj/machinery/door/airlock)
				LAGCHECK(LAG_LOW)
				if (A.z != Z_LEVEL_STATION)
					continue
				if (!(istype(A, /obj/machinery/door/airlock/maintenance) || istype(A, /obj/machinery/door/airlock/pyro/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/glass/maintenance)))
					continue
				A.req_access = null

			sleep(actualtime)

			for (var/area/A in world)
				LAGCHECK(LAG_LOW)
				if (A.z != Z_LEVEL_STATION)
					continue
				if (A.do_not_irradiate)
					continue
				else
					if (!A.irradiated)
						A.irradiated = TRUE
						A.icon_state = "blowout"
					for (var/turf/T in A)
						if (rand(0,1000) < 5 && istype(T,/turf/simulated/floor))
							Artifact_Spawn(T)

			siren.repeat = FALSE
			siren.channel = 5
			siren.volume = 50

			for (var/mob/N in mobs)
				N.flash(3 SECONDS)

	#ifndef UNDERWATER_MAP
			for (var/turf/space/S in world)
				LAGCHECK(LAG_LOW)
				if (S.z == Z_LEVEL_STATION)
					S.color = src.space_color
				else
					break
	#endif

			world << siren

			sleep(0.4 SECONDS)

			blowout = TRUE

			var/sound/blowoutsound = sound('sound/misc/blowout.ogg')
			blowoutsound.repeat = 0
			blowoutsound.channel = 5
			blowoutsound.volume  = 20
			world << blowoutsound
			boutput(world, "<span class='alert'><B>WARNING</B>: Mass radiation has struck [station_name(1)]. Do not leave safety until all radiation alerts have been cleared.</span>")

			for (var/mob/M in mobs)
				SPAWN_DBG(0)
					shake_camera(M, 400, 16)

			sleep(rand(1.5 MINUTES,2 MINUTES)) // drsingh lowered these by popular request.
			command_alert("Radiation levels lowering [station_or_ship()]wide. ETA 60 seconds until all areas are safe.", "Anomaly Alert")

			sleep(rand(25 SECONDS,50 SECONDS)) // drsingh lowered these by popular request

			for (var/area/A in world)
				LAGCHECK(LAG_LOW)
				if (A.z != Z_LEVEL_STATION)
					continue
				if (!A.permarads)
					A.irradiated = FALSE
				A.icon_state = null
			blowout = FALSE

			command_alert("All radiation alerts onboard [station_name(1)] have been cleared. You may now leave the tunnels freely. Maintenance doors will regain their normal access requirements shortly.", "All Clear")

	#ifndef UNDERWATER_MAP
			for (var/turf/space/S in world)
				LAGCHECK(LAG_LOW)
				if (S.z == Z_LEVEL_STATION)
					S.color = null
				else
					break
	#endif
			for (var/mob/N in mobs)
				N.flash(3 SECONDS)

			sleep(rand(25 SECONDS,50 SECONDS))

			for_by_tcl(A, /obj/machinery/door/airlock)
				if (A.z != Z_LEVEL_STATION)
					break
				if (!(istype(A, /obj/machinery/door/airlock/maintenance) || istype(A, /obj/machinery/door/airlock/pyro/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/glass/maintenance)))
					continue
				A.req_access = list(access_maint_tunnels)
