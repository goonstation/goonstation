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
		for (var/turf/T as anything in src.coverage)
			if(islist(T.camera_coverage_emitters))
				T.camera_coverage_emitters -= src
	camera_coverage_controller.update_turfs(src.coverage)
	src.coverage = null

	STOP_TRACKING
	. = ..()

/datum/component/camera_coverage_emitter/Initialize(range = CAM_RANGE, active = TRUE)
	. = ..()
	if (!istype(src.parent, /atom))
		return COMPONENT_INCOMPATIBLE

	var/atom/parent_atom = src.parent

	src.range = range
	src.active = active
	src.turf = get_turf(parent_atom.loc)

	if (current_state > GAME_STATE_WORLD_NEW)
		camera_coverage_controller.update_emitter(src)

	RegisterSignal(parent, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(on_move))


/datum/component/camera_coverage_emitter/UnregisterFromParent()
	if(parent.GetComponent(/datum/component/complexsignal/outermost_movable))
		UnregisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED)
	. = ..()

/datum/component/camera_coverage_emitter/proc/on_move(atom/target, previous_loc, new_loc, direction)
	src.turf = get_turf(new_loc)

	camera_coverage_controller.update_emitter(src)

/datum/component/camera_coverage_emitter/proc/set_active(active = TRUE)
	src.active = active

	camera_coverage_controller.update_emitter(src)
