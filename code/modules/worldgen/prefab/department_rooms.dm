/**
 * So this file is basically about swappable departments.
 * Maps this doesn't apply to is stuff that uses non TEG/singulos
 *
 */

var/list/prefabbed_engineering = list("cogmap")

TYPEINFO(/datum/mapPrefab/department_room)
	folder = "department_rooms"

/datum/mapPrefab/department_room/
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

	cogmap
		tags += "cogmap"
		engineering
			associated_fab = /datum/mapPrefab/department_room/engineering_room
			department_type = "engineering"
			tags += "engineering"

/datum/mapPrefab/department_room/engineering_room
	tags = list()
	post_init()
		var/filename = filename_from_path(src.prefabPath)
