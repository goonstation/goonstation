/**
 * So this file is basically about swappable departments.
 * Steps:
 *
 * You plonk down a landmark in the bottom left (southwest) corner of the replacable area
 * this is of course /obj/landmark/department, and this tells the game that this room is here
 *
 * then you have different versions of said room in the /assets/maps/department_rooms folder
 * using the naming scheme mapname_departmentname_prefabname e.g. cogmap_engineering_Nuclear
 * this gets picked up by /datum/mapPrefab/department_room
 * then, ideally, at runtime, through admin commands (or even expensive cargo requests), the entire area defined by the landmark's width and height vars
 *
 * this is more of a framework for future work than it is an actual intended feature
 * the original idea was that certain maps could have multiple different engine rooms based on engine type
 * which could be swapped pre round start.
 * This framework aims to allow that.
 */

TYPEINFO(/datum/mapPrefab/department_room)
	folder = "department_rooms"

/datum/mapPrefab/department_room
	maxNum = 1
	required = TRUE
	post_init()
		var/filename = filename_from_path(src.prefabPath)
		var/regex/room_type = regex(@"^.*_(\d+)\.dmm$")

proc/build_departments()
	for_by_tcl(landmark, /obj/landmark/department)
		landmark.apply()

/obj/landmark/department
	var/width = null
	var/height = null
	var/associated_fab = /datum/mapPrefab/department_room/
	var/department_type = null
	var/list/tags = list()
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
		var/datum/mapPrefab/department_room/room_prefab = pick_map_prefab(/datum/mapPrefab/department_room)
		room_prefab.prefabSizeX = width
		room_prefab.prefabSizeY = height
		if(isnull(room_prefab))
			CRASH("No department room prefab found for current map")
		room_prefab.applyTo(src.loc)
		logTheThing(LOG_DEBUG, null, "Applied [department_type] department room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

	engineering
		associated_fab = /datum/mapPrefab/department_room/engineering_room
		department_type = "engineering"

		clarion
			tags = list("engineering","clarion")

