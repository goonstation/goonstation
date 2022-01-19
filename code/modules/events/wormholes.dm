/datum/random_event/major/wormholes
	name = "Wormholes"
	centcom_headline = "Spatial Anomalies"
	centcom_message = "Multiple localized spatial anomalies detected on the station. Personnel are advised to avoid any spatial distortions."
	required_elapsed_round_time = 20 MINUTES

	event_effect(var/source)
		..()
		var/turf/holepick = null
		var/turf/targpick = null

		SPAWN_DBG(0)
			for(var/holes = rand(100,200), holes > 0, holes--)
				holepick = pick(wormholeturfs)
				targpick = pick(wormholeturfs)
				var/obj/portal/P = new /obj/portal/wormhole
				P.set_loc( holepick )
				P.target = targpick
				SPAWN_DBG(rand(18 SECONDS,32 SECONDS))
					qdel(P)
				if (rand(1,1000) == 1)
					Artifact_Spawn(holepick)
				sleep(rand(1,15))

/proc/event_wormhole_buildturflist()
	for(var/turf/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		if(istype(T,/turf/simulated/floor) && !(locate(/obj/window) in T))
			wormholeturfs += T

		LAGCHECK(LAG_LOW)
