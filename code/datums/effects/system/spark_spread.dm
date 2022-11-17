/datum/effects/system/spark_spread
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/total_sparks = 0 // To stop it being spammed and lagging!
	var/list/livesparks = new

/datum/effects/system/spark_spread/proc/set_up(n = 3, c = 0, loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

/datum/effects/system/spark_spread/proc/attach(atom/atom)
	holder = atom

/datum/effects/system/spark_spread/proc/detach()
	holder = null

/datum/effects/system/spark_spread/proc/update()
	while(1)
		if(!livesparks.len && !holder)
			qdel(src)
			return
		var/do_hotspot
		for(var/obj/effects/sparks/sparks in livesparks)
			do_hotspot = 0
			// get direction
			var/direction = livesparks[sparks] >> 4
			// get distance
			var/distance = livesparks[sparks] & 15
			if(distance)
				// Only do hotspot for tiles that dont already have sparks on them
				if(!(locate(/obj/effects/sparks) in get_step(sparks, direction)))
					do_hotspot = 1

				// Move the sparks
				step(sparks, direction)
				distance--

				if(do_hotspot)
					var/turf/T = get_turf(sparks)
					if(istype(T, /turf))
						T.hotspot_expose(1000, 100)

				livesparks[sparks] = direction << 4 | distance
			else
				// Kill the spark in 20 ticks
				SPAWN(2 SECONDS)//ugly fuckin spawn todo fix
					if (sparks && !sparks.disposed)
						livesparks -= sparks
						qdel(sparks)
						src.total_sparks-- //  this might not be the intended behaviour but who knows at this point
		sleep(0.5 SECONDS)

/datum/effects/system/spark_spread/proc/start()
	if(istype(holder, /atom/movable))
		location = get_turf(holder)
	SPAWN(0)
		if(istype(src.location, /turf))
			src.location.hotspot_expose(1000, 100)
		// Create sparks
		for(var/i = 0, i < src.number, i++)
			if(src.total_sparks > 20)
				break;

			// Check spawn limits
			if(!limiter.canISpawn(/obj/effects/sparks))
				continue
			// Create sparks
			var/obj/effects/sparks/sparks = new /obj/effects/sparks
			sparks.set_loc(src.location)
			src.total_sparks++

			// Set direction and distance to travel
			var/direction
			if(src.cardinals)
				direction = pick(cardinal)
			else
				direction = pick(alldirs)
			var/distance = rand(1,3)
			// Store direction and distance to travel as the high quad and low quad of the low byte
			livesparks[sparks] = direction << 4 | distance
		sleep(0.5 SECONDS)
		update()
