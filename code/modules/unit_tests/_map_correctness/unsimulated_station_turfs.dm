/datum/map_correctness_check/unsimulated_station_turfs
	check_name = "Unsimulated Station Turfs"

/datum/map_correctness_check/unsimulated_station_turfs/run_check()
	. = list()

	for (var/turf/unsimulated/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		if (!istype(T.loc, /area/station))
			continue
		if (istype(T.loc, /area/station/hallway/secondary/oshan_arrivals))
			continue
		if (istype(T.loc, /area/station/hangar/arrivals))
			continue
		if (istype(T.loc, /area/station/crewquarters/cryotron))
			continue

		. += src.format_position(T)
