/**
 * So this file is basically about swappable Engineering departements.
 * Maps this doesn't apply to is stuff that uses non TEG/singulos
 * i.e. Nadir and Oshan
 * Only maps in the list prefabbed_engineering will undergo the process
 * In order to use:
 * place in folder /assets/maps/engine_rooms/ a file by the name of MAPNAME_ENGINETYPE
 * where enginetype is either "TEG" "SINGULO" or "NUKE"
 *
 */

// some overrides which i am putting here while i test it
// they can go somewhere else later
#define TEG_OVERRIDE
#define SINGULO_OVERRIDE
#define NUCLEAR_OVERRIDE

// puttin it in a macro called ENGINE_OVERRIDE_STATUS because idk what happens if i define a variable outside a proc / type
#ifdef TEG_OVERRIDE
#define ENGINE_OVERRIDE_STATUS = "TEG"
#elif defined(SINGULO_OVERRIDE)
#define ENGINE_OVERRIDE_STATUS = "SINGULO"
#elif defined(NUCLEAR_OVERRIDE)
#define ENGINE_OVERRIDE_STATUS = "NUKE"
#else
#define ENGINE_OVERRIDE_STATUS "Random"
#endif

var/map = "cogmap" // this is supposed to be detected somehow
var/list/prefabbed_engineering = list("cogmap")

TYPEINFO(/datum/mapPrefab/engineering_room)
	folder = "engine_rooms"

/datum/mapPrefab/engineering_room
	maxNum = 1
	required = TRUE
	var/width = null
	var/height = null
	post_init()
		for(var/tag in src.tags)
			src.prefabSizeX = mapenginesizes[width]
			src.prefabSizeY = mapenginesizes[height]

		var/filename = filename_from_path(src.prefabPath)
		var/regex/engine_type = regex(@"^.*_(\d+)\.dmm$")
		if ("Random" == ENGINE_OVERRIDE_STATUS )
			src.probability = 100
			return
		else if ("TEG" == ENGINE_OVERRIDE_STATUS)
			if (engine_type == "TEG")
				src.probability = 100
			else
				src.probability = 0
		else if ("SINGULO" == ENGINE_OVERRIDE_STATUS)
			if (engine_type == "SINGULO")
				src.probability = 100
			else
				src.probability = 0
		else if ("NUKE" == ENGINE_OVERRIDE_STATUS)
			if (engine_type == "NUKE")
				src.probability = 100
			else
				src.probability = 0

proc/build_Engineering()
	shuffle_list(by_type[/obj/landmark/engineering_room])
	for_by_tcl(landmark, /obj/landmark/engineering_room)
		landmark.apply()


/obj/landmark/engineering_room
	var/map = null
	var/width = null
	var/height = null
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "landmark"
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

	proc/apply(width, height)
		var/datum/mapPrefab/engineering_room/room_prefab = pick_map_prefab(/datum/mapPrefab/engineering_room, list(map))
		room_prefab.width = width
		room_prefab.height = height
		if(isnull(room_prefab))
			CRASH("No engine room prefab found for map: " + map)
		room_prefab.applyTo(src.loc)
		logTheThing(LOG_DEBUG, null, "Applied engine room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

	cogmap1
		name = "Cogmap 1 Engine room"
		map = "Cogmap 1"
		icon_state = 'engine'

#undef ENGINE_OVERRIDE_STATUS
