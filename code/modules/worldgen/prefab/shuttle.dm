
TYPEINFO(/datum/mapPrefab/shuttle)
	folder = "shuttles"

	prefab_from_path(full_path, local_path)
		RETURN_TYPE(/datum/mapPrefab/shuttle)
		var/dir = null
		var/list/path_parts = splittext(local_path, "/")
		for(var/potential_dir in dirnames)
			if(potential_dir in path_parts)
				dir = dirnames[potential_dir]
		if(isnull(dir))
			return null
		var/name = local_path
		var/is_small = ("small" in path_parts)
		return new/datum/mapPrefab/shuttle(full_path, name, dir, is_small)


/datum/mapPrefab/shuttle
	var/dir = null
	var/small = FALSE
	#ifdef UPSCALED_MAP
	prefabSizeX = 26 * 2
	prefabSizeY = 26 * 2
	#else
	prefabSizeX = 26
	prefabSizeY = 26
	#endif

	New(prefabPath, name, dir, small=FALSE)
		..()
		src.prefabPath = prefabPath
		src.name = name
		src.dir = dir
		src.small = small
		if(src.small)
			// unknown size
			prefabSizeX = null
			prefabSizeY = null
			LAZYLISTADD(src.tags, "small")
		LAZYLISTADD(src.tags, dir_to_dirname(dir))

	verify_position(turf/target)
		return src.dir == map_settings.escape_dir

	post_cleanup(turf/target, datum/loadedProperties/props)
		// fixes for stuff that doesn't load properly, might be removable once we improve DMM loader using Init()
		for(var/turf/T in block(target, locate(props.maxX, props.maxY, props.maxZ)))
			T.UpdateIcon()
			for(var/obj/machinery/light/L in T)
				L.seton(TRUE)
			for(var/obj/window/W in T)
				W.UpdateIcon()
			if(small)
				if(!istype(T.loc, /area/shuttle) && (istype(T, /turf/unsimulated/outdoors/grass) || istype(T, /turf/unsimulated/nicegrass)))
					T.ReplaceWith(/turf/unsimulated/floor/shuttlebay , keep_old_material=FALSE, force=TRUE)
				for(var/obj/lattice/lattice in T)
					qdel(lattice)

	proc/load()
		if(!small)
			return map_settings.load_shuttle(prefabPath)
		else
			var/area/current_shuttle = locate(map_settings.escape_centcom)
			var/min_x = INFINITY
			var/min_y = INFINITY
			var/min_z = INFINITY
			for (var/turf/T in current_shuttle)
				min_x = min(min_x, T.x)
				min_y = min(min_y, T.y)
				min_z = min(min_z, T.z)
				T.ReplaceWithSpaceForce()
				for(var/obj/O in T)
					if(!istype(O, /obj/overlay/tile_effect))
						qdel(O)
			var/turf/target_turf = locate(min_x, min_y, min_z)
			. = map_settings.load_shuttle(src, load_loc_override=target_turf)
			current_shuttle = locate(map_settings.escape_centcom)
