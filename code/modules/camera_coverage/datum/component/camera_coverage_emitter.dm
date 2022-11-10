TYPEINFO(/datum/component/camera_coverage_emitter)
	initialization_args = list(
		ARG_INFO("range", DATA_INPUT_NUM, "the coverage range", CAM_RANGE),
		ARG_INFO("active", DATA_INPUT_BOOL, "is it active by default", TRUE),
	)

/datum/component/camera_coverage_emitter
	var/list/cooldowns // Why do datums not have this...
	var/range
	var/active
	var/turf/turf
	var/list/turf/coverage

/datum/component/camera_coverage_emitter/New(list/raw_args)
	. = ..()
	START_TRACKING

/datum/component/camera_coverage_emitter/disposing()
	if (length(src.coverage))
		// Remove ourselves from the turfs and update their aiImage directly, we dont need to do any fancy checks here.
		for (var/turf/T in src.coverage)
			T.camera_coverage_emitters -= src
	camera_coverage_controller.update_turfs(src.coverage)
	src.coverage = null

	STOP_TRACKING
	. = ..()

/datum/component/camera_coverage_emitter/Initialize(range = CAM_RANGE, active = TRUE)
	if (!istype(src.parent, /atom))
		CRASH("camera_coverage_emitter added on non-atom type")

	var/atom/parent_atom = src.parent

	src.range = range
	src.active = active
	src.turf = get_turf(parent_atom.loc)

	if (current_state > GAME_STATE_WORLD_NEW)
		camera_coverage_controller.update_emitter(src)

	RegisterSignals(parent, list(COMSIG_MOVABLE_SET_LOC, COMSIG_MOVABLE_MOVED), .proc/on_move)

	// If our parent is not on a turf but on an atom instead, update when their
	// location is changed. This is necessary due to the many cases of a
	// /obj/machinery/camera being placed on another atom to create a camera
	// coverage around them. See cyborgs or small bots for examples. These should
	// slowly be migrated after a solution is made for the camera network that an
	// /obj/machinery/camera creates.
	if (!isturf(parent_atom.loc) && isatom(parent_atom.loc))
		RegisterSignals(parent_atom.loc, list(COMSIG_MOVABLE_SET_LOC, COMSIG_MOVABLE_MOVED), .proc/on_move)

/datum/component/camera_coverage_emitter/proc/on_move(atom/target, new_loc, previous_loc, direction)
	src.turf = get_turf(new_loc)

	camera_coverage_controller.update_emitter(src)

/datum/component/camera_coverage_emitter/proc/set_active(active = TRUE)
	src.active = active

	camera_coverage_controller.update_emitter(src)
