/datum/map_correctness_check/directional_objects
	check_name = "Directional Objects Without Supporting Walls"
	check_prefabs = FALSE

/datum/map_correctness_check/directional_objects/run_check()
	. = list()

	for_by_tcl(directional, /datum/component/directional)
		if (directional.flags & DOES_NOT_REQUIRE_WALL)
			continue

		var/atom/A = directional.parent
		var/turf/T = get_step(A, A.dir)
		if (!isturf(T))
			continue

		// The turf is a wall.
		if (istype(T, /turf/simulated/wall) || istype(T, /turf/unsimulated/wall))
			continue

		// The turf has a window in its contents.
		if ((locate(/obj/mapping_helper/wingrille_spawn) in T) || (locate(/obj/window) in T))
			continue

		// The turf has a girder in its contents.
		if (locate(/obj/structure/girder) in T)
			continue

		// The turf has a grille in its contents.
		if (locate(/obj/mesh/grille) in T)
			continue

		// Special areas that are permitted invalid directional objects.
		var/area/area = get_area(T)
		if (istype(area, /area/shuttle/escape))
			continue

		. += src.format_position(A)


SET_UP_CI_TRACKING(/datum/component/directional)
