/datum/object_creator
	var/datum/admins/admin_holder
	var/root_type
	var/list/type_strings
	var/picked_x
	var/picked_y
	var/picked_z

/datum/object_creator/New(datum/admins/A, root)
	..()
	admin_holder = A
	if (!admin_can_spawn())
		return
	root_type = root || /obj
	type_strings = list()
	// no abstract or hidden types
	for (var/T in filtered_concrete_typesof(root_type, /proc/filter_admin_spawnable))
		type_strings += "[T]"

/datum/object_creator/ui_state(mob/user)
	return tgui_admin_state

/datum/object_creator/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ObjectCreator", "Spawner")
		ui.open()

/datum/object_creator/ui_static_data(mob/user)
	. = list()
	.["types"] = type_strings
	.["root"] = "[root_type]"
	.["world_max_x"] = world.maxx
	.["world_max_y"] = world.maxy
	.["world_max_z"] = world.maxz

/datum/object_creator/ui_data(mob/user)
	. = list()
	if (src.picked_x && src.picked_y && src.picked_z)
		.["picked_x"] = src.picked_x
		.["picked_y"] = src.picked_y
		.["picked_z"] = src.picked_z


/datum/object_creator/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if ("spawn")
			if (!src.admin_can_spawn())
				return
			var/list/types = params["types"]
			if (!islist(types) || !length(types))
				return
			if (length(types) > 5)
				tgui_alert(usr, "Select five or fewer types only.")
				return
			var/list/dirty_paths = types
			var/list/paths = list()
			var/list/removed_paths = list()
			for (var/dirty_path in dirty_paths)
				var/path = text2path(dirty_path)
				if (!path)
					removed_paths += dirty_path
				else if (!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
					removed_paths += dirty_path
				else
					paths += path
			if (!paths)
				return
			else if (length(removed_paths))
				tgui_alert(usr, "Spawning of these objects is blocked:\n" + jointext(removed_paths, "\n"))
				logTheThing(LOG_ADMIN, usr, "tried to spawn blocked objects: [english_list(removed_paths)]", "admin")
				return
			var/offset_type = params["offset_type"]
			var/x
			var/y
			var/z
			if(offset_type == "absolute")
				x = clamp(text2num(params["x"]), 1, world.maxx)
				y = clamp(text2num(params["y"]), 1, world.maxy)
				z = clamp(text2num(params["z"]), 1, world.maxz)
			else
				x = clamp(text2num(params["x"]), -world.maxx, world.maxx)
				y = clamp(text2num(params["y"]), -world.maxy, world.maxy)
				z = clamp(text2num(params["z"]), -world.maxz, world.maxz)
			var/direction = text2num(params["direction"]) || SOUTH
			var/count = clamp(text2num(params["count"]), 1, 100)
			var/spawn_x, spawn_y, spawn_z
			if(offset_type == "absolute")
				spawn_x = x
				spawn_y = y
				spawn_z = z
			else
				if(!usr.loc)
					tgui_alert(usr, "Cannot spawn relative to your position: you have no position.")
					return
				spawn_x = usr.loc.x + x
				spawn_y = usr.loc.y + y
				spawn_z = usr.loc.z + z
			var/turf/spawn_turf = locate(spawn_x, spawn_y, spawn_z)
			if(!spawn_turf)
				tgui_alert(usr, "Cannot spawn stuff at ([spawn_x], [spawn_y], [spawn_z]): invalid turf.")
				return
			for(var/i = 1, i <= count, i++)
				for(var/path in paths)
					var/atom/thing
					if(ispath(path, /turf))
						thing = spawn_turf.ReplaceWith(path, FALSE, TRUE, FALSE, TRUE)
						thing.set_dir(direction)
					else
						new /dmm_suite/preloader(spawn_turf, list("dir" = direction))
						thing = new path(spawn_turf)
						if(isobj(thing))
							var/obj/O = thing
							O.initialize(TRUE)
				LAGCHECK(LAG_LOW)
			logTheThing(LOG_ADMIN, usr, "created [count] [english_list(paths)] at [log_loc(spawn_turf)]", "admin")
			// for(var/path in paths)
			// 	if(ispath(path, /mob))
			// 		message_admins("[key_name(usr)] created [length(count) > 1 ? "a" : count] [english_list(paths, 1)]")
			// 		break
			// 	LAGCHECK(LAG_LOW)
			return TRUE
		if ("pick_coordinate")
			var/turf/T = pick_ref(usr)
			if (isturf(T))
				src.picked_x = T.x
				src.picked_y = T.y
				src.picked_z = T.z
				return TRUE

/datum/object_creator/proc/admin_can_spawn()
	if(!admin_holder || admin_holder.level < LEVEL_ADMIN)
		tgui_alert(admin_holder.owner, "You need to be at least an Adminstrator to spawn objects.")
		return FALSE
	if(!config.allow_admin_spawning)
		tgui_alert(admin_holder.owner, "Object spawning is disabled on this server.")
		return FALSE
	return TRUE
