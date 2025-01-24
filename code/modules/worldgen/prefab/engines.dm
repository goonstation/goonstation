TYPEINFO(/datum/mapPrefab/engine_room)
	folder = "engine_rooms"

/datum/mapPrefab/engine_room
	name = null
	maxNum = 1
	post_init()
		var/filename = filename_from_path(src.prefabPath, strip_extension=FALSE)
		var/regex/probability_regex = regex(@"^(.*)_(\d+)\.dmm$")
		if(probability_regex.Find(filename))
			src.probability = text2num(probability_regex.group[2])
			src.name = probability_regex.group[1]
		else
			src.probability = 100
			src.name = src.generate_default_name()

	post_cleanup(turf/target, datum/loadedProperties/props)
		. = ..()
		var/comp1type = null
		var/comp2type = null
		// dumb hack currently for pamgoc
		// currently the prefab system does not allow multiple prefabs with the same name (even if in different folders)
		// so pamgoc has reversed names in the spirit of the map, someone should fix the prefab issue later
		#ifdef REVERSED_MAP
		switch(reverse_text(src.name))
		#else
		switch(src.name)
		#endif
			if("choice", "choicedevtest")
				comp1type = /obj/machinery/engine_selector //type select computer
				comp2type = /obj/landmark/engine_computer/two
			if("nuclear", "nucleardevtest")
				comp1type = /obj/machinery/power/nuclear/reactor_control
				comp2type = /obj/machinery/power/nuclear/turbine_control
			if("TEG", "TEGdevtest")
				comp1type = /obj/machinery/computer/power_monitor/smes
				comp2type = /obj/machinery/power/reactor_stats
			if("singularity", "singularitydevtest")
				comp1type = /obj/machinery/computer3/generic/engine
				comp2type = /obj/machinery/computer/power_monitor/smes
			else
				CRASH("Selected an unknown engine type - did you forget to put it here?")

		for_by_tcl(comp, /obj/landmark/engine_computer)
			showswirl(comp, TRUE)
			if(istype(comp, /obj/landmark/engine_computer/one))
				comp.replaceWith(comp1type)
			else
				comp.replaceWith(comp2type)

		for(var/turf/T as anything in block(target, locate(props.maxX, props.maxY, target.z)))
			leaveresidual(T)

		for(var/turf/T as anything in block(locate(target.x-1, target.y-1, target.z), locate(props.maxX+2, props.maxY+2, target.z)))
			for(var/obj/O in T)
				O.initialize(FALSE)
				O.UpdateIcon()
		makepowernets()


/obj/landmark/engine_room
	var/size = null
#ifdef IN_MAP_EDITOR
	icon = 'icons/effects/mapeditor/engine_room.dmi'
	icon_state = "11x11engine_room"
#else
	icon = null
	icon_state = null
#endif
	deleted_on_start = FALSE
	add_to_landmarks = FALSE
	opacity = 1
	invisibility = 0
	plane = PLANE_FLOOR

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/apply(var/type_force = null)
		var/list/datum/mapPrefab/engine_room/prefab_list = get_map_prefabs(/datum/mapPrefab/engine_room)
		var/list/datum/mapPrefab/engine_room/room_prefabs = list()
		for(var/name in prefab_list)
			var/datum/mapPrefab/prefab = prefab_list[name]
			if(lowertext(map_settings.name) in prefab.tags)
				if(!type_force)
					room_prefabs[prefab] = prefab.probability
				else if(prefab.name == type_force)
					room_prefabs[prefab] = TRUE //so we can have prefabs that only spawn when chosen and don't otherwise
		if(!length(room_prefabs))
			CRASH("No engine room prefab found for map: [lowertext(map_settings.name)] [type_force ? "and forced type [type_force]" : ""]")
		var/datum/mapPrefab/engine_room/room_prefab = weighted_pick(room_prefabs)
		room_prefab.applyTo(src.loc, DMM_OVERWRITE_OBJS)
		logTheThing(LOG_DEBUG, null, "Applied engine room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

/obj/landmark/engine_room/devtest
	#ifdef IN_MAP_EDITOR
	icon = 'icons/effects/mapeditor/engine_room_devtest.dmi'
	icon_state = "19x19engine_room"
#else
	icon = null
	icon_state = null
#endif

/obj/landmark/engine_computer
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/replaceWith(var/type)
		if(!type)
			qdel(src)
			return
		var/obj/comp = new type(src.loc)
		comp.initialize()
		qdel(src)

/obj/landmark/engine_computer/one
	name = "comp1"

/obj/landmark/engine_computer/two
	name = "comp2"

/obj/machinery/engine_selector
	name = "Engine Teleport Request Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "teleport"
	desc = "A computer for requesting teleportation and installation of an engine"
	density = TRUE
	anchored = ANCHORED

	attack_hand(mob/user)
		. = ..()
		var/list/datum/mapPrefab/engine_room/prefab_list = get_map_prefabs(/datum/mapPrefab/engine_room)
		//filter by map and rename
		var/list/choices = list()
		for(var/name in prefab_list)
			var/datum/mapPrefab/prefab = prefab_list[name]
			if(lowertext(map_settings.name) in prefab.tags)
				if(prefab.name == "choice" || prefab.name == "choicedevtest")
					continue
				choices += prefab.name
		var/engine_choice = tgui_input_list(user, "Choose an engine type!", "Engine Selector", choices)
		if(src.disposed || !engine_choice)
			return //don't apply twice
		logTheThing(LOG_STATION, user, "selected the [engine_choice] engine prefab")
		new /obj/landmark/engine_computer/one(src.loc) //replace our computer landmark so it can be swapped out
		for_by_tcl(landmark, /obj/landmark/engine_room)
			landmark.apply(engine_choice)
		qdel(src)
