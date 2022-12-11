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

// puttin it in a macro called engine_override_status because idk what happens if i define a variable outside a proc / type
var/engine_override_status = "Random"
#ifdef TEG_OVERRIDE
engine_override_status = "TEG"
#elif defined(SINGULO_OVERRIDE)
engine_override_status = "SINGULO"
#elif defined(NUCLEAR_OVERRIDE)
engine_override_status = "NUKE"
#endif

var/map = "cogmap" // this is supposed to be detected somehow
var/list/prefabbed_engineering = list("cogmap")

TYPEINFO(/datum/mapPrefab/engineering_room)
	folder = "engine_rooms"

/datum/mapPrefab/engineering_room
	maxNum = 1
	required = TRUE
	post_init()

		var/filename = filename_from_path(src.prefabPath)
		var/regex/engine_type = regex(@"^.*_(\d+)\.dmm$")
		if ("Random" == engine_override_status)
			src.probability = 100
			return
		else
			if (engine_type == engine_override_status)
				src.probability = 100
			else
				src.probability = 0
			return

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
		room_prefab.prefabSizeX = width
		room_prefab.prefabSizeY = height
		if(isnull(room_prefab))
			CRASH("No engine room prefab found for map: " + map)
		room_prefab.applyTo(src.loc)
		logTheThing(LOG_DEBUG, null, "Applied engine room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

	cogmap1
		name = "Cogmap 1 Engine room"
		map = "Cogmap 1"
		icon_state = 'engine'
