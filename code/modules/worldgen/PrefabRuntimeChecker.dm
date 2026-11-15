#ifdef CI_RUNTIME_CHECKING

/**
  * The `placeAllPrefabs()` proc, as the name suggests, places all the prefabs
	* on the map in rows. It overwrites existing objects, mobs, and turfs when doing so.
	*
	* Do not use this proc on a live server.
	*
	* If you run it locally do not move your mob into the location turfs are
	* being placed (your client will be `qdel`'d).
	*
	* This proc was designed to be used with totally blank maps, where
	* every tile is either space or trench.
	*
	* Prefabs are found by looking for concrete types of
	* `/datum/mapPrefab/mining/underwater,space,anywhere`.
	* To add a new prefab to be checked, simply create a type for it.
  */
/proc/placeAllPrefabs()
	var/startTime = world.timeofday
	CI.announce("Generating prefabs...")
#ifdef UNDERWATER_MAP
	var/list/prefab_types = concrete_typesof(/datum/mapPrefab/mining/underwater) + concrete_typesof(/datum/mapPrefab/mining/anywhere)
#else
	var/list/prefab_types = concrete_typesof(/datum/mapPrefab/mining/space) + concrete_typesof(/datum/mapPrefab/mining/anywhere)
#endif
	var/list/datum/mapPrefab/prefabs = list()
	for (var/prefab_type in prefab_types)
		prefabs += new prefab_type()
	CI.announce("Found [length(prefabs)] prefabs...")
	place_prefabs_for_checking(prefabs)
	CI.announce("Placed prefabs in [((world.timeofday - startTime)/10)] seconds!")

/// Empty tiles left between prefabs loaded at the same time
/// Right now this still is tons of margin before we get to 2 zlevels
/// Mainly for stupid crap that link-checks range around it like cloners
#define PREFAB_CHECK_GAP 5

/**
 * Loads `prefabs` on the station z-level in a row-major grid (tallest first).
 * Each batch is loaded + initialised, then spawned procs get a second to run,
 * then the map correctness checks possibly run, and then the batch is cleared.
 */
/proc/place_prefabs_for_checking(list/datum/mapPrefab/prefabs, correctness_label)
	var/min_coord = 1 + AST_MAPBORDER
	var/x = min_coord
	var/y = min_coord
	var/row_height = 0

	for (var/datum/mapPrefab/prefab as anything in sortListCopy(prefabs, /proc/cmp_prefab_height_dsc))
		if (x + prefab.prefabSizeX - 1 > (world.maxx - AST_MAPBORDER)) // new row time!
			x = min_coord
			y += row_height + PREFAB_CHECK_GAP
			row_height = 0
		if (y + prefab.prefabSizeY - 1 > (world.maxy - AST_MAPBORDER)) // z-level is full :(
			CI.announce("The z-level is full, resetting...")
			finish_prefab_check_batch(correctness_label)
			x = min_coord
			y = min_coord

		var/turf/T = locate(x, y, Z_LEVEL_STATION)

		// Load as if during world init, like real prefabs are
		var/real_state = current_state
		current_state = GAME_STATE_WORLD_NEW

		var/placed = prefab.applyTo(T, DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
		current_state = real_state // only the prefab's New() should think it's world init
		if (!placed)
			CRASH("Prefab [prefab.prefabPath] could not be placed at [T.x], [T.y].")
		CI.placed_prefabs += list(list(prefab.prefabPath, x, y, x + prefab.prefabSizeX - 1, y + prefab.prefabSizeY - 1, T.z))
		x += prefab.prefabSizeX + PREFAB_CHECK_GAP
		row_height = max(row_height, prefab.prefabSizeY)

	if (length(CI.placed_prefabs))
		finish_prefab_check_batch(correctness_label)

/proc/cmp_prefab_height_dsc(datum/mapPrefab/a, datum/mapPrefab/b)
	return b.prefabSizeY - a.prefabSizeY

/proc/finish_prefab_check_batch(correctness_label)
	var/max_x = 0
	var/max_y = 0
	for (var/list/prefab as anything in CI.placed_prefabs)
		max_x = max(max_x, prefab[4])
		max_y = max(max_y, prefab[5])
	var/turf/bottom_left = locate(1 + AST_MAPBORDER, 1 + AST_MAPBORDER, Z_LEVEL_STATION)
	var/turf/top_right = locate(min(max_x + PREFAB_CHECK_GAP, world.maxx), min(max_y + PREFAB_CHECK_GAP, world.maxy), Z_LEVEL_STATION)

	// Initialise every object, contents included
	for (var/obj/O in world)
		var/turf/T = get_turf(O)
		if (T?.z == Z_LEVEL_STATION && T.x >= bottom_left.x && T.y >= bottom_left.y && T.x <= top_right.x && T.y <= top_right.y)
			O.initialize(FALSE)

	sleep(1 SECOND)
	if (correctness_label)
		check_map_correctness(correctness_label)

	// Delete everything in the batch's area
	for (var/turf/T as anything in block(bottom_left, top_right))
		for (var/atom/movable/AM as anything in T)
			if (!istype(AM, /obj/overlay/tile_effect))
				qdel(AM)

	// Reset the turfs and area
	var/area/space = locate(/area/space)
	for (var/list/prefab as anything in CI.placed_prefabs)
		for (var/turf/T as anything in block(locate(prefab[2], prefab[3], Z_LEVEL_STATION), locate(prefab[4], prefab[5], Z_LEVEL_STATION)))
			space.contents += T.ReplaceWithSpaceForce()

	CI.placed_prefabs.len = 0

#undef PREFAB_CHECK_GAP
#endif
