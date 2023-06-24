TYPEINFO(/datum/mapPrefab/engine_room)
	folder = "engine_rooms"

/datum/mapPrefab/engine_room
	maxNum = 1

	post_cleanup(turf/target, datum/loadedProperties/props)
		. = ..()
		for(var/obj/O in bounds(target.x-1, target.y-1, props.maxX+1, props.maxY+1, target.z))
			O.initialize()

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

