/**
 * So this file is basically about swappable Engineering departements.
 * Maps this doesn't apply to is stuff that uses non TEG/singulos
 * i.e. Nadir and Oshan
 *
 */
// some overrides which i am putting here while i test it
#define TEG_OVERRIDE
#define SINGULO_OVERRIDE
#define NUCLEAR_OVERRIDE

var/list/mapenginesizes = list("cogmap" = list(30,19))

TYPEINFO(/datum/mapPrefab/engineering_room)
	folder = "engine_rooms"

/datum/mapPrefab/engineering_room
	maxNum = 1
	required = TRUE

	post_init()
		for(var/tag in src.tags)
			src.prefabSizeX = mapenginesizes["cogmap"[1]]
			src.prefabSizeY = mapenginesizes["cogmap"[2]]

		var/filename = filename_from_path(src.prefabPath)
		var/regex/engine_type = regex(@"^.*_(\d+)\.dmm$")
		#ifdef TEG_OVERRIDE
			if (engine_type == "TEG")
				src.probability = 100
			else
				src.probability = 0
			return
		#endif
		#ifdef SINGULO_OVERRIDE
			if (engine_type == "SINGULO")
				src.probability = 100
			else
				src.probability = 0
			return
		#endif
		#ifdef NUCLEAR_OVERRIDE
			if (engine_type == "NUKE")
				src.probability = 100
			else
				src.probability = 0
			return
		#endif
		src.probability = 100

proc/build_Engineering()
	shuffle_list(by_type[/obj/landmark/engineering_room])
	for_by_tcl(landmark, /obj/landmark/engineering_room)
		landmark.apply()


/obj/landmark/engineering_room
	var/map = null
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "engine"
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
		var/datum/mapPrefab/engineering_room/room_prefab = pick_map_prefab(/datum/mapPrefab/engineering_room, list(size))
		if(isnull(room_prefab))
			CRASH("No engine room prefab found for map: " + map)
		room_prefab.applyTo(src.loc)
		logTheThing(LOG_DEBUG, null, "Applied engine room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

	cogmap1
		map = "Cogmap 1"
		icon_state = 'engine'

