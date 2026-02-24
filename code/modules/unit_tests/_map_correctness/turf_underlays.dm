/datum/map_correctness_check/turf_underlays
	check_name = "Turfs With Underlays"

/datum/map_correctness_check/turf_underlays/run_check()
	. = list()
	var/list/whitelist_types = list(
		/turf/simulated/floor/airless/plating/catwalk,
		/turf/simulated/floor/airbridge,
		/turf/simulated/wall/airbridge,
	)

	for (var/turf/T as anything in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		if (!length(T.underlays) || istypes(T, whitelist_types))
			continue

		. += "[src.format_position(T)] has underlays, likely due to duplicate turfs on the map."
