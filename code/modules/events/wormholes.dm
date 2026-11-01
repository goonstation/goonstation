/datum/random_event/major/wormholes
	name = "Wormholes"
	centcom_headline = "Spatial Anomalies"
	centcom_message = "Multiple localized spatial anomalies detected on the station. Personnel are advised to avoid any spatial distortions."
	centcom_origin = ALERT_ANOMALY
	required_elapsed_round_time = 20 MINUTES

	event_effect(var/source)
		..()
		var/turf/holepick = null
		var/turf/targpick = null

		SPAWN(0)
			for(var/i in 1 to length(random_floor_turfs))
				holepick = pick(random_floor_turfs)
				targpick = pick(random_floor_turfs)
				if (prob(1) && prob(10))
					var/obj/vortex/V = new /obj/vortex
					V.set_loc(holepick)
					SPAWN(rand(18 SECONDS, 32 SECONDS))
						qdel(V)
				else
					var/obj/portal/P = new /obj/portal/wormhole
					P.set_loc(holepick)
					P.set_target(targpick)
					SPAWN(rand(18 SECONDS, 32 SECONDS))
						qdel(P)
				if (rand(1,1000) == 1)
					Artifact_Spawn(holepick)
				sleep(rand(1, 15))

var/global/list/turf/random_floor_turfs = null

/proc/build_random_floor_turf_list()
	random_floor_turfs = list()
	var/list/turf/station_z_turfs = block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION))
	var/rand_amt = rand(150, 250)

	#ifdef UNIT_TESTS
	rand_amt = 10
	#endif

	while (rand_amt > length(random_floor_turfs))
		var/turf/T = pick(station_z_turfs)
		if (T in random_floor_turfs)
			continue
		var/area/A = get_area(T)
		if (IS_ARRIVALS(A) || (A.teleport_blocked && !istype(A, /area/station/security)))
			continue
		if(istype(T,/turf/simulated/floor) && !(locate(/obj/window) in T))
			random_floor_turfs += T
			LAGCHECK(LAG_LOW)
