
TYPEINFO(/datum/mapPrefab)
	var/folder = null
	proc/prefab_from_path(path)
		RETURN_TYPE(/datum/mapPrefab)
		CRASH("Not implemented")

ABSTRACT_TYPE(/datum/mapPrefab)
/datum/mapPrefab
	var/name = null
	var/probability = 100
	var/maxNum = 0
	var/prefabPath = null
	var/prefabSizeX = null
	var/prefabSizeY = null

	New()
		..()
		if(isnull(name) && !isnull(prefabPath))
			src.generate_default_name()

	proc/generate_default_name()
		src.name = filename_from_path(prefabPath, strip_extension=TRUE)

	proc/adjust_position(turf/target)
		RETURN_TYPE(/turf)
		// Fail if prefab doesn't fit
		if(!isnull(prefabSizeX) && (target.x + prefabSizeX) > (world.maxx - AST_MAPBORDER))
			stack_trace("mapPrefab: Prefab '[name]' with path '[prefabPath]' X size exceeds map size")
			return null

		if(!isnull(prefabSizeY) && (target.y + prefabSizeY) > (world.maxy - AST_MAPBORDER))
			stack_trace("mapPrefab: Prefab '[name]' with path '[prefabPath]' Y size exceeds map size")
			return null

		return target

	proc/verify_position(turf/target)
		return TRUE

	proc/pre_cleanup(turf/target)
		return

	proc/post_cleanup(turf/target, datum/loadedProperties/props)
		return

	proc/applyTo(var/turf/target, overwrite_args=0)
		target = src.adjust_position(target)

		if(isnull(target) || !verify_position(target))
			return FALSE

		var/loaded = file2text(prefabPath)
		if(!loaded)
			CRASH("mapPrefab: Prefab '[name]' with path '[prefabPath]' not found")

		pre_cleanup(target)

		var/dmm_suite/D = new/dmm_suite()
		var/datum/loadedProperties/props = D.read_map(loaded, target.x, target.y, target.z, prefabPath, overwrite=overwrite_args)
		if(!isnull(prefabSizeX) && prefabSizeX != props.maxX - props.sourceX + 1 || !isnull(prefabSizeY) && prefabSizeY != props.maxY - props.sourceY + 1)
			CRASH("size of prefab [prefabPath] is incorrect ([prefabSizeX]x[prefabSizeY] != [props.maxX - props.sourceX + 1]x[props.maxY - props.sourceY + 1])")

		post_cleanup(target, props)

		return TRUE




proc/get_map_prefabs(prefab_type)
	RETURN_TYPE(/list)
	var/static/list/prefab_cache = null
	if(isnull(prefab_cache))
		prefab_cache = list()
	if(prefab_type in prefab_cache)
		return prefab_cache[prefab_type]

	var/typeinfo/datum/mapPrefab/typeinfo = get_type_typeinfo(prefab_type)
	if(isnull(typeinfo.folder))
		CRASH("mapPrefab: Prefab type '[prefab_type]' has no folder set")

	prefab_cache[prefab_type] = list()

	for(var/base_path in list("assets/maps/[typeinfo.folder]/", "+secret/assets/[typeinfo.folder]/"))
		for(var/filepath in recursive_flist(base_path, list_folders=FALSE))
			var/datum/mapPrefab/prefab = typeinfo.prefab_from_path(filepath)
			if(isnull(prefab))
				continue
			if(isnull(prefab.name))
				prefab.generate_default_name()
			prefab_cache[prefab_type][prefab.name] = prefab

	return prefab_cache[prefab_type]
