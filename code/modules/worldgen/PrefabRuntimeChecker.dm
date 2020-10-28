/proc/filter_underwater_prefab(var/prefab_type)
	var/datum/generatorPrefab/M = prefab_type
	.= initial(M?.underwater)
#ifndef UNDERWATER_MAP
	.=!.
#endif
	return

/proc/placeAllPrefabs()
	var/startTime = world.timeofday
	boutput(world, "<span class='alert'>Generating prefabs...</span>")
	var/list/prefab_types = filtered_concrete_typesof(/datum/generatorPrefab, /proc/filter_underwater_prefab)
	boutput(world, "<span class='alert'>Found [length(prefab_types)] prefabs...</span>")
	for (var/prefab_type in prefab_types)
		var/datum/generatorPrefab/M = new prefab_type()
		var/turf/T = locate(1+AST_MAPBORDER, 1+AST_MAPBORDER, Z_LEVEL_STATION)
		var/loaded = file2text(M.prefabPath)
		var/dmm_suite/D = new/dmm_suite()
		D.read_map(loaded,T.x,T.y,T.z,M.prefabPath, DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
		boutput(world, "<span class='alert'>Prefab placement [M.type][M.required?" (REQUIRED)":""] succeeded. [T] @ [showCoords(T.x, T.y, T.z)]")
		sleep(1 SECOND)
	boutput(world, "<span class='alert'>Generated prefabs Level in [((world.timeofday - startTime)/10)] seconds!")
