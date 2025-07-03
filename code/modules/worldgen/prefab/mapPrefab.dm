
TYPEINFO(/datum/mapPrefab)
	var/stored_as_subtypes = FALSE
	var/folder = null
	proc/prefab_from_path(full_path, local_path)
		RETURN_TYPE(/datum/mapPrefab)
		var/list/path_parts = splittext(local_path, "/")
		var/typepath = text2path(splittext("[src.type]", "/typeinfo")[2])
		var/datum/mapPrefab/prefab = new typepath
		prefab.prefabPath = full_path
		prefab.tags = path_parts.Copy(1, length(path_parts))
		prefab.name = full_path
		prefab.post_init()
		return prefab

ABSTRACT_TYPE(/datum/mapPrefab)
/datum/mapPrefab
	var/name = null
	var/probability = 100
	var/required = FALSE //! If 1 we will try to always place thing thing no matter what.
	var/maxNum = -1 //! If -1 there's no limit.
	var/prefabPath = null
	var/prefabSizeX = null
	var/prefabSizeY = null
	var/tags = null
	var/nPlaced = 0

	New()
		..()
		if(isnull(name) && !isnull(prefabPath))
			src.generate_default_name()
		src.init()

	proc/init()
		return

	proc/post_init()
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

		var/dmm_suite/D = new/dmm_suite(debug_id="prefab [name], path [prefabPath]")
		var/datum/loadedProperties/props = D.read_map(loaded, target.x, target.y, target.z, prefabPath, flags=overwrite_args)
		if(!isnull(prefabSizeX) && prefabSizeX != props.maxX - props.sourceX + 1 || !isnull(prefabSizeY) && prefabSizeY != props.maxY - props.sourceY + 1)
			CRASH("size of prefab [prefabPath] is incorrect ([prefabSizeX]x[prefabSizeY] != [props.maxX - props.sourceX + 1]x[props.maxY - props.sourceY + 1])")

		post_cleanup(target, props)

		src.nPlaced++

		return TRUE



/**
 * Gets all prefabs of a given type.
 */
proc/get_map_prefabs(prefab_type)
	RETURN_TYPE(/list)
	var/static/list/prefab_cache = null
	if(isnull(prefab_cache))
		prefab_cache = list()
	if(prefab_type in prefab_cache)
		return prefab_cache[prefab_type]

	var/typeinfo/datum/mapPrefab/typeinfo = get_type_typeinfo(prefab_type)
	if(isnull(typeinfo.folder) && !typeinfo.stored_as_subtypes)
		CRASH("mapPrefab: Prefab type '[prefab_type]' has no folder set and its prefabs are not stored as subtypes")

	prefab_cache[prefab_type] = list()

	if(typeinfo.stored_as_subtypes)
		for(var/datum/mapPrefab/prefabType as anything in concrete_typesof(prefab_type, cache=FALSE))
			var/datum/mapPrefab/prefab = get_singleton(prefabType)
			if(prefab.name in prefab_cache[prefab_type])
				stack_trace("mapPrefab: Prefab type '[prefab_type]' has multiple prefabs with the same name '[prefab.name]'")
			prefab_cache[prefab_type][prefab.name] = prefab
	else
		for(var/base_path in list("assets/maps/[typeinfo.folder]/", "+secret/assets/[typeinfo.folder]/"))
			for(var/filepath in recursive_flist(base_path, list_folders=FALSE))
				var/datum/mapPrefab/prefab = typeinfo.prefab_from_path(filepath, splittext(filepath, base_path)[2])
				if(isnull(prefab))
					continue
				if(isnull(prefab.name))
					prefab.generate_default_name()
				if(prefab.name in prefab_cache[prefab_type])
					stack_trace("mapPrefab: Prefab type '[prefab_type]' has multiple prefabs with the same name '[prefab.name]'")
				// TODO: figure out a way how do allow duplicate prefab names if they are from different folders
				// but note that currently some code rightly assumes that get_map_prefabs(foo)[bar].name == bar
				prefab_cache[prefab_type][prefab.name] = prefab

	return prefab_cache[prefab_type]

/**
 * Picks a random prefab from given prefab type. Filters the prefabs picked based on the given tags.
 * Choice is performed by a weighted random choice based on the prefab's probability.
 * Prefabs marked as required are always picked first.
 *
 * Prefab max count is respected. However, note that the count of a prefab is only updated in prefab's applyTo() function.
 */
proc/pick_map_prefab(prefab_type, list/wanted_tags_any=null, list/wanted_tags_all=null,list/unwanted_tags=null)
	RETURN_TYPE(/datum/mapPrefab)
	var/prefab_list = get_map_prefabs(prefab_type)
	if (!length(prefab_list))
		return null

	var/list/required = list()
	var/list/choices = list()
	for (var/name in prefab_list)
		var/datum/mapPrefab/prefab = prefab_list[name]
		if (!(prefab.tags & wanted_tags_any)) // Uses bitflags inclusively IE if it has any wanted tag its viable
			continue
		if (length(prefab.tags & wanted_tags_all) != length(wanted_tags_all)) // Compares length exclusive IE needs exactly that tag
			continue
		if (prefab.maxNum > 0 && prefab.nPlaced >= prefab.maxNum)
			continue
		choices[prefab] = prefab.probability
		if (prefab.required)
			required[prefab] = prefab.probability

	if (length(required))
		return weighted_pick(required)

	return weighted_pick(choices)

proc/get_prefab_tags()
	var/wanted_tags = null
	wanted_tags	= PREFAB_ANYWHERE
	if (map_currently_underwater)
		wanted_tags |= PREFAB_NADIR_SAFE
#if defined(MAP_OVERRIDE_OSHAN)
		wanted_tags |= PREFAB_OSHAN | PREFAB_NADIR_UNSAFE
#endif
#if defined(MAP_OVERRIDE_NEON)
		wanted_tags |= PREFAB_OSHAN | PREFAB_NADIR_UNSAFE
#endif
#if defined(MAP_OVERRIDE_NADIR)
		wanted_tags |= PREFAB_NADIR
#endif
	else
		wanted_tags |= PREFAB_SPACE
	return wanted_tags
