/**
 * Similar to the prefab runtime checker. The following text is mostly plagiarised from PrefabRuntimeChecker.dm
 *
 * The proc places all random rooms on the map, at (3, 3, 1).
 * It overwrites existing objects, mobs, and turfs when doing so.
 * This proc will only work correctly if RUNTIME_CHECKING is defined,
 * as some turfs cannot be replaced using `turf/proc/ReplaceWith()`
 * and RUNTIME_CHECKING fixes this.
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
 * `/datum/mapPrefab/random_room`. To add a new prefab to be checked, simply
 * create a type for it.
 */
#if defined(CI_RUNTIME_CHECKING)
var/global/loaded_prefab_path
#endif

/proc/placeAllRandomRooms()
#if defined(CI_RUNTIME_CHECKING)
	var/startTime = world.timeofday
	boutput(world, SPAN_ALERT("Generating random rooms..."))
	var/list/room_types = get_map_prefabs(/datum/mapPrefab/random_room)
	boutput(world, SPAN_ALERT("Found [length(room_types)] random rooms..."))
	var/list/bad_prefabs = list()
	for (var/room_type in room_types)
		var/datum/mapPrefab/random_room/R = room_types[room_type]
		var/turf/T = locate(1+AST_MAPBORDER, 1+AST_MAPBORDER, Z_LEVEL_STATION)
		var/loaded = file2text(R.prefabPath)
		var/dmm_suite/D = new/dmm_suite()
		D.read_map(loaded, T.x, T.y, T.z, R.prefabPath, DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
		boutput(world, SPAN_ALERT("Prefab placement [R.prefabPath][R.required?" (REQUIRED)":""] succeeded. [T] @ [log_loc(T)]"))
		global.loaded_prefab_path = R.prefabPath
		check_map_correctness()
		// we don't have a ref to prefab in `check_map_correctness` so we do the check here
		var/turf/other_corner = locate(T.x + R.prefabSizeX, T.y + R.prefabSizeY, T.z)
		for(var/turf/T2 in block(T, other_corner))
			if (!istype(get_area(T2, /area/dmm_suite/clear_area)))
				bad_prefabs += R.prefabPath
				break
		sleep(1 SECOND)
		// cleanup
		for(var/turf/T2 in block(T, other_corner))
			for(var/x in T2)
				try
					qdel(x)
				catch // suppress errors
					;
			T2.ReplaceWithSpaceForce()
	global.loaded_prefab_path = null
	if (length(bad_prefabs))
		CRASH("Random rooms using non `/area/dmm_suite/clear_area` areas:\n"+ jointext(bad_prefabs, "\n"))
	boutput(world, SPAN_ALERT("Generated prefabs Level in [((world.timeofday - startTime)/10)] seconds!"))
#else
	CRASH("This proc only works if CI_RUNTIME_CHECKING is defined")
#endif
