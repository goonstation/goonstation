/datum/random_event/major/blowout
	name = "Radioactive Blowout"
	required_elapsed_round_time = 40 MINUTES
	var/space_color = "#ff4646"

	event_effect()
		..()
		var/timetoreachsec = rand(1,9)
		var/timetoreach = rand(30,60)
		var/actualtime = timetoreach * 10 + timetoreachsec

		for (var/mob/N in mobs) // why N?  why not M?
			N.flash(3 SECONDS)
		var/sound/siren = sound('sound/misc/airraid_loop_short.ogg')
		siren.repeat = 1
		siren.channel = 5
		siren.volume = 50 // wire note: lets not deafen players with an air raid siren
		world << siren
		command_alert("Extreme levels of radiation detected approaching the [station_or_ship()]. All personnel have [timetoreach].[timetoreachsec] seconds to enter a maintenance tunnel or radiation safezone. Maintenance doors have temporarily had their access requirements removed. This is not a test.", "Anomaly Alert")

		for (var/obj/machinery/door/airlock/A in by_type[/obj/machinery/door])
			LAGCHECK(LAG_LOW)
			if (A.z != 1)
				break
			if (!(istype(A, /obj/machinery/door/airlock/maintenance) || istype(A, /obj/machinery/door/airlock/pyro/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/glass/maintenance)))
				continue
			A.req_access = null

		sleep(actualtime)

		for (var/area/A in world)
			LAGCHECK(LAG_LOW)
			if (A.z != 1)
				break
			if (A.do_not_irradiate)
				continue
			else
				if (!A.irradiated)
					A.irradiated = 1
				for (var/turf/T in A)
					if (rand(0,1000) < 5 && T.z == 1 && istype(T,/turf/simulated/floor))
						Artifact_Spawn(T)
					else
						continue

		siren.repeat = 0
		siren.channel = 5
		siren.volume = 50

		for (var/mob/N in mobs)
			N.flash(3 SECONDS)

#ifndef UNDERWATER_MAP
		for (var/turf/space/S in world)
			LAGCHECK(LAG_LOW)
			if (S.z == 1)
				S.color = src.space_color
			else
				break
#endif

		world << siren

		sleep(0.4 SECONDS)

		blowout = 1

		var/sound/blowoutsound = sound('sound/misc/blowout.ogg')
		blowoutsound.repeat = 0
		blowoutsound.channel = 5
		blowoutsound.volume  = 20
		world << blowoutsound
		boutput(world, "<span class='alert'><B>WARNING</B>: Mass radiation has struck [station_name(1)]. Do not leave safety until all radiation alerts have been cleared.</span>")

		for (var/mob/M in mobs)
			SPAWN_DBG(0)
				shake_camera(M, 400, 2) // wire note: lowered strength from 840 to 400, by popular request

		sleep(rand(1.5 MINUTES,2 MINUTES)) // drsingh lowered these by popular request.
		command_alert("Radiation levels lowering [station_or_ship()]wide. ETA 60 seconds until all areas are safe.", "Anomaly Alert")

		sleep(rand(25 SECONDS,50 SECONDS)) // drsingh lowered these by popular request

		for (var/area/A in world)
			LAGCHECK(LAG_LOW)
			if (A.z != 1)
				break
			if (!A.permarads)
				A.irradiated = 0
		blowout = 0

		command_alert("All radiation alerts onboard [station_name(1)] have been cleared. You may now leave the tunnels freely. Maintenance doors will regain their normal access requirements shortly.", "All Clear")

#ifndef UNDERWATER_MAP
		for (var/turf/space/S in world)
			LAGCHECK(LAG_LOW)
			if (S.z == 1)
				S.color = null
			else
				break
#endif
		for (var/mob/N in mobs)
			N.flash(3 SECONDS)

		sleep(rand(25 SECONDS,50 SECONDS))

		for (var/X in by_type[/obj/machinery/door/airlock])
			var/obj/machinery/door/airlock/A = X
			if (A.z != 1)
				break
			if (!(istype(A, /obj/machinery/door/airlock/maintenance) || istype(A, /obj/machinery/door/airlock/pyro/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/maintenance) || istype(A, /obj/machinery/door/airlock/gannets/glass/maintenance)))
				continue
			A.req_access = list(access_maint_tunnels)
