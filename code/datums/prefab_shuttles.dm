var/list/prefab_shuttles = list()

/datum/prefab_shuttle
	var/prefab_path = null
	var/name = null
	var/dir = null
	var/small = FALSE

	New(prefab_path, name, dir, small=FALSE)
		..()
		src.prefab_path = prefab_path
		src.name = name
		src.dir = dir
		src.small = small

	proc/load()
		if(!small)
			if(src.dir == map_settings.escape_dir)
				return map_settings.load_shuttle(prefab_path)
			else
				return FALSE
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
			. = map_settings.load_shuttle(prefab_path, load_loc_override=target_turf, cleanup_grass_and_stuff=TRUE)
			current_shuttle = locate(map_settings.escape_centcom)

proc/get_prefab_shuttles()
	RETURN_TYPE(/list)
	var/static/list/prefab_shuttles = null
	if(isnull(prefab_shuttles))
		prefab_shuttles = list()
		for(var/base_path in list("assets/maps/shuttles/", "+secret/assets/shuttles/"))
			for(var/dir_name in flist(base_path))
				var/dir = dirname_to_dir(copytext(dir_name, 1, length(dir_name)))
				if(isnull(dir))
					continue
				for(var/fname in flist("[base_path][dir_name]"))
					var/is_folder = copytext(fname, length(fname), length(fname) + 1) == "/"
					if(!is_folder)
						var/name = "[dir_name][fname]"
						prefab_shuttles[name] = new/datum/prefab_shuttle("[base_path][dir_name][fname]", name, dir)
						continue
					for(var/inner_fname in flist("[base_path][dir_name][fname]"))
						var/name = "[dir_name][fname][inner_fname]"
						prefab_shuttles[name] = new/datum/prefab_shuttle("[base_path][dir_name][fname][inner_fname]", name, dir, fname == "small/")
	return prefab_shuttles
