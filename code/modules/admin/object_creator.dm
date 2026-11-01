/datum/object_creator
	var/datum/admins/admin_holder
	var/root_type
	var/list/type_strings
	var/picked_x
	var/picked_y
	var/picked_z
	var/const/max_types = 10

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
		ui = new(user, src, "AdminObjectSpawner", "Spawner")
		ui.set_autoupdate(FALSE) // No need to resend the client 15,000 types no thank you
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
			if (length(types) > max_types)
				tgui_alert(usr, "Select [max_types] or fewer types only.")
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
			var/effect = params["effect"] || "None"
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
			src.spawn_with_effect(paths, spawn_turf, direction, count, effect, usr)
			logTheThing(LOG_ADMIN, usr, "created [count] [english_list(paths)] at [log_loc(spawn_turf)] (effect: [effect])", "admin")
			return
		if ("pick_coordinate")
			var/turf/T = pick_ref(usr)
			if (isturf(T))
				src.picked_x = T.x
				src.picked_y = T.y
				src.picked_z = T.z
				. = TRUE

/datum/object_creator/proc/admin_can_spawn()
	. = TRUE
	if(!admin_holder || admin_holder.level < LEVEL_ADMIN)
		tgui_alert(admin_holder.owner, "You need to be at least an Adminstrator to spawn objects.")
		return FALSE
	if(!config.allow_admin_spawning)
		tgui_alert(admin_holder.owner, "Object spawning is disabled on this server.")
		return FALSE

/datum/object_creator/proc/spawn_with_effect(list/paths, turf/T, dir, count, effect, mob/user)
	if(!T || !paths || !length(paths))
		return
	var/is_supply = (effect == "Supplydrop")
	var/list/turf/turf_paths = list()
	var/list/atom/movable/non_turf_paths = list()
	for(var/P in paths) // If we support turfs as well as atoms some day
		if(ispath(P, /turf))
			turf_paths += P
		else
			non_turf_paths += P
	if(is_supply && length(turf_paths))
		// Spawn turfs right away BEFORE pod so final turf exists when items land.
		for(var/i in 1 to count)
			for(var/path in turf_paths)
				var/turf/new_turf = T.ReplaceWith(path, FALSE, TRUE, FALSE, TRUE)
				new_turf?.set_dir(dir)
			LAGCHECK(LAG_LOW)
	// Handle supplydrop separately (we do NOT spawn atoms now; pod spawns them later)
	if(is_supply && length(non_turf_paths))
		for(var/i in 1 to count)
			new/obj/effect/supplymarker/safe(T, 3 SECONDS, non_turf_paths, TRUE)
		return
	// Non-supplydrop effects: spawn everything, then run effect once total
	for(var/i in 1 to count)
		for(var/path in paths)
			var/atom/thing
			if(ispath(path, /turf))
				thing = T.ReplaceWith(path, FALSE, TRUE, FALSE, TRUE)
				thing?.set_dir(dir)
			else
				new /dmm_suite/preloader(T, list("dir" = dir))
				thing = new path(T)
				if(isobj(thing))
					var/obj/O = thing
					O.initialize(TRUE)
			if(thing && (isobj(thing) || ismob(thing) || isturf(thing)))
				thing.set_dir(dir)
		LAGCHECK(LAG_LOW)
	// Effects that go after spawning
	if(effect == "Blink")
		blink(T)
	else if(effect == "Poof")
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(T)
		playsound(T, 'sound/effects/poff.ogg', 50, TRUE)
