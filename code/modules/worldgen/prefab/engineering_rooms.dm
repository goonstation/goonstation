/**
 * So this file is basically about swappable Engineering departements.
 * Maps this doesn't apply to is stuff that uses non TEG/singulos
 * i.e. Nadir and Oshan
 *
 */
// some overrides which i am putting here while i test it
// #define TEG_OVERRIDE
// #define SINGULO_OVERRIDE

var/list/mapenginesizes = list("cogmap" = list(30,19))

TYPEINFO(/datum/mapPrefab/random_room)
	folder = "engine_rooms"

/datum/mapPrefab/engineering_room
	maxNum = 1
	required = TRUE

	post_init()
		var/regex/size_regex = regex(@"^(\d+)x(\d+)$")
		for(var/tag in src.tags)
			if(size_regex.Find(tag))
				src.prefabSizeX = mapenginesizes["cogmap"[1]]
				src.prefabSizeY = mapenginesizes["cogmap"[2]]

		var/filename = filename_from_path(src.prefabPath)
		var/regex/probability_regex = regex(@"^.*_(\d+)\.dmm$")
		if(probability_regex.Find(filename))
			src.probability = text2num(probability_regex.group[1])

proc/build_Engineering()
	#ifdef TEG_OVERRIDE

		return
	#endif

	#ifdef SINGULO_OVERRIDE
		return
	#endif
	null == null
	return


/obj/landmark/engineering_room
	var/size = null
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "random_room"
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
		var/datum/mapPrefab/random_room/room_prefab = pick_map_prefab(/datum/mapPrefab/random_room, list(size))
		if(isnull(room_prefab))
			CRASH("No random room prefab found for size: " + size)
		room_prefab.applyTo(src.loc)
		logTheThing(LOG_DEBUG, null, "Applied random room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

	size3x3
		size = "3x3"
		icon = 'icons/effects/mapeditor/3x3tiles.dmi'

	size3x5
		size = "3x5"
		icon = 'icons/effects/mapeditor/3x5tiles.dmi'

	size5x3
		size = "5x3"
		icon = 'icons/effects/mapeditor/5x3tiles.dmi'
