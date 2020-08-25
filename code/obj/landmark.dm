
var/global/list/list/turf/landmarks = list()

proc/pick_landmark(name, default=null)
	if(!(name in landmarks))
		return default
	return pick(landmarks[name])

/obj/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	invisibility = 101
	var/deleted_on_start = TRUE
	var/add_to_landmarks = TRUE
	var/data = null // data to associatively save with the landmark
	var/name_override = null

	ex_act()
		return

/obj/landmark/New()
	if(src.add_to_landmarks)
		if(!landmarks)
			landmarks = list()
		var/name = src.name_override ? src.name_override : src.name
		if(!landmarks[name])
			landmarks[name] = list()
		landmarks[name][src.loc] = src.data
	if(src.deleted_on_start)
		qdel(src)
	else
		..()

var/global/list/job_start_locations = list()

/obj/landmark/start
	name = "start"
	icon_state = "x"
	add_to_landmarks = FALSE

	New()
		if (job_start_locations)
			if (!islist(job_start_locations[src.name]))
				job_start_locations[src.name] = list(src.loc)
			else
				job_start_locations[src.name] += src.loc
		..()

/obj/landmark/start/latejoin
	name = LANDMARK_LATEJOIN
	add_to_landmarks = TRUE

/obj/landmark/cruiser_entrance
	name = "cruiser_entrance"

/obj/landmark/escape_pod_succ
	name = LANDMARK_ESCAPE_POD_SUCCESS
	icon_state = "xp"
	New()
		src.data = src.dir // save dir
		..()

/obj/landmark/tutorial_start
	name = LANDMARK_TUTORIAL_START

/obj/landmark/halloween
	name = LANDMARK_HALLOWEED_SPAWN

/obj/landmark/asteroid_spawn_blocker //Blocks the creation of an asteroid on this tile, as you would expect
	name = "asteroid blocker"
	icon_state = "x4"
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

/obj/landmark/magnet_center
	name = LANDMARK_MAGNET_CENTER
	icon_state = "x"

/obj/landmark/magnet_shield
	name = LANDMARK_MAGNET_SHIELD
	icon_state = "x"

/obj/landmark/latejoin_missile
	name = "missile latejoin spawn marker"
	name_override = LANDMARK_LATEJOIN_MISSILE
	icon_state = "x"
	dir = NORTH

	New()
		src.data = src.dir // save dir
		..()
	north
		name = "missile latejoin spawn marker (north)"
		dir = NORTH

/obj/landmark/ass_arena_spawn
	name = LANDMARK_ASS_ARENA_SPAWN
	icon_state = "x"

/obj/landmark/interesting
	// Use this to place cryptic clues to be picked up by the T-ray, because trying to remember which floortile you varedited is shit. For objects and mobs, just varedit.
	name = "Interesting turf spawner"
	desc = "Sets the var/interesting of the target turf, then deletes itself"
	interesting = ""
	add_to_landmarks = FALSE

	New() //use initialize() later and test ok
		var/turf/T = src.loc
		T.interesting = src.interesting
		..()

// LONG RANGE TELEPORTER
// consider refactoring to be associative the other way around later

/obj/landmark/lrt //for use with long range teleporter locations, please add new subtypes of this for new locations and use those
	name = "lrt landmark"
	name_override = LANDMARK_LRT

	New()
		src.data = src.name // store name
		..()

/obj/landmark/lrt/gemv
	name = "Geminorum V"

/obj/landmark/lrt/workshop
	name = "Hidden Workshop"
