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
/proc/placeAllRandomRooms()
#if defined(CI_RUNTIME_CHECKING)
	var/startTime = world.timeofday
	boutput(world, "<span class='alert'>Generating random rooms...</span>")
	var/list/room_types = concrete_typesof(/datum/mapPrefab/random_room)
	boutput(world, "<span class='alert'>Found [length(room_types)] random rooms...</span>")
	for (var/room_type in room_types)
		var/datum/mapPrefab/random_room/R = new room_type()
		var/turf/T = locate(1+AST_MAPBORDER, 1+AST_MAPBORDER, Z_LEVEL_STATION)
		var/loaded = file2text(R.prefabPath)
		var/dmm_suite/D = new/dmm_suite()
		D.read_map(loaded, T.x, T.y, T.z, R.prefabPath, DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
		boutput(world, "<span class='alert'>Prefab placement [R.type][R.required?" (REQUIRED)":""] succeeded. [T] @ [log_loc(T)]")
		sleep(1 SECOND)
		// cleanup
		var/turf/other_corner = locate(T.x + R.prefabSizeX, T.y + R.prefabSizeY, T.z)
		for(var/turf/T2 in block(T, other_corner))
			for(var/x in T2)
				try
					qdel(x)
				catch // suppress errors
					;
			T2.ReplaceWithSpaceForce()
	boutput(world, "<span class='alert'>Generated prefabs Level in [((world.timeofday - startTime)/10)] seconds!")
#else
	CRASH("This proc only works if CI_RUNTIME_CHECKING is defined")
#endif
