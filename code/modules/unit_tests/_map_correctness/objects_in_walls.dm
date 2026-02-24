/datum/map_correctness_check/objects_in_walls
	check_name = "Unanchored Objects In Walls"

/datum/map_correctness_check/objects_in_walls/run_check()
	. = list()

	for (var/turf/simulated/wall/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		for (var/obj/O in T)
			if (O.anchored)
				continue

			. += src.format_position(O)

	for (var/turf/unsimulated/wall/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		for (var/obj/O in T)
			if (O.anchored)
				continue

			. += src.format_position(O)
