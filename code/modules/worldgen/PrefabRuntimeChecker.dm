/**
  * The `placeAllPrefabs()` proc, as the name suggests, places all the prefabs
	* on the map, at (3, 3, 1). It overwrites existing objects, mobs, and turfs
	* when doing so. This proc will only work correctly if RUNTIME_CHECKING is
	* defined, as some turfs cannot be replaced using `turf/proc/ReplaceWith()`
	* and RUNTIME_CHECKING fixes this.
	*
	* Do not use this proc on a live server.
	*
	* If you run it locally do not move your mob into the location turfs are
	* being placed (your client will be `qdel`'d).
	*
	* This proc was designed to be used with totally blank maps, where
	* every tile is either space or trench. UNDERWATER_MAP is used in
	* `/proc/filter_underwater_prefab()` to choose underwater or space
	* prefabs appropriately, depending on the type of map.
	*
	* Prefabs are found by looking for concrete types of
	* `/datum/mapPrefab/mining`. To add a new prefab to be checked, simply
	* create a type for it.
  */
/proc/placeAllPrefabs()
#if defined(RUNTIME_CHECKING)
	var/startTime = world.timeofday
	boutput(world, "<span class='alert'>Generating prefabs...</span>")
	var/list/prefab_types = filtered_concrete_typesof(/datum/mapPrefab/mining, /proc/filter_underwater_prefab)
	boutput(world, "<span class='alert'>Found [length(prefab_types)] prefabs...</span>")
	for (var/prefab_type in prefab_types)
		var/datum/mapPrefab/mining/M = new prefab_type()
		var/turf/T = locate(1+AST_MAPBORDER, 1+AST_MAPBORDER, Z_LEVEL_STATION)
		var/loaded = file2text(M.prefabPath)
		var/dmm_suite/D = new/dmm_suite()
		D.read_map(loaded,T.x,T.y,T.z,M.prefabPath, DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
		boutput(world, "<span class='alert'>Prefab placement [M.type][M.required?" (REQUIRED)":""] succeeded. [T] @ [log_loc(T)]")
		sleep(1 SECOND)
		// cleanup
		var/turf/other_corner = locate(T.x + M.prefabSizeX, T.y + M.prefabSizeY, T.z)
		for(var/turf/T2 in block(T, other_corner))
			for(var/x in T2)
				try
					qdel(x)
				catch // suppress errors
					;
			T2.ReplaceWithSpaceForce()
	boutput(world, "<span class='alert'>Generated prefabs Level in [((world.timeofday - startTime)/10)] seconds!")
#else
	CRASH("This proc only works if RUNTIME_CHECKING is defined")
#endif

/proc/filter_underwater_prefab(var/prefab_type)
	var/datum/mapPrefab/mining/M = prefab_type
	.= initial(M?.underwater)
#ifndef UNDERWATER_MAP
	.=!.
#endif
	return
