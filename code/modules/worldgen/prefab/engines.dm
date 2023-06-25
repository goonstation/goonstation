TYPEINFO(/datum/mapPrefab/engine_room)
	folder = "engine_rooms"

/datum/mapPrefab/engine_room
	maxNum = 1

	post_cleanup(turf/target, datum/loadedProperties/props)
		. = ..()
		for(var/obj/O in bounds(target.x-1, target.y-1, props.maxX+1, props.maxY+1, target.z))
			O.initialize()
		var/comp1type = null
		var/comp2type = null
		var/engine_type = filename_from_path(src.prefabPath, strip_extension=TRUE)
		switch(engine_type)
			if("none")
				comp1type = null //type select computer
				comp2type = null
			if("nuclear")
				comp1type = /obj/machinery/power/nuclear/reactor_control
				comp2type = /obj/machinery/power/nuclear/turbine_control
			if("TEG")
				comp1type = /obj/machinery/computer/power_monitor
				comp2type = /obj/machinery/power/reactor_stats
			if("singularity")
				comp1type = /obj/machinery/computer3/generic/engine
				comp2type = /obj/machinery/computer/power_monitor

		for_by_tcl(comp1, /obj/landmark/engine_computer/one)
			comp1.replaceWith(comp1type)
		for_by_tcl(comp2, /obj/landmark/engine_computer/two)
			comp2.replaceWith(comp2type)


/obj/landmark/engine_room
	var/size = null
	icon = 'icons/effects/mapeditor/11x11engine_room.dmi'
	icon_state = "11x11engine_room"
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

	proc/apply()
		var/datum/mapPrefab/engine_room/room_prefab = pick_map_prefab(/datum/mapPrefab/engine_room, list(lowertext(map_settings.name)))
		if(isnull(room_prefab))
			CRASH("No engine room prefab found for map: " + lowertext(map_settings.name))
		room_prefab.applyTo(src.loc)
		logTheThing(LOG_DEBUG, null, "Applied engine room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

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
		var/obj/comp = new type(src.loc)
		comp.initialize()
		qdel(src)

/obj/landmark/engine_computer/one
	name = "comp1"

/obj/landmark/engine_computer/two
	name = "comp2"
