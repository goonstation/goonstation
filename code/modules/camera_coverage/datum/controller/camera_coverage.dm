var/global/datum/controller/camera_coverage/camera_coverage_controller

/datum/controller/camera_coverage
	var/list/cooldowns
	var/list/datum/component/camera_coverage_emitter/emitter_update_queue
	var/list/turf/turf_update_queue

/**
 * Called at world setup, creates an image on all turfs that will overlay for the AI when a turf is not visible in the camera coverage. At the end will update all camera coverage.
 */
/datum/controller/camera_coverage/proc/setup()
#if defined(IM_REALLY_IN_A_FUCKING_HURRY_HERE) && !defined(SPACEMAN_DMM)
	return
#endif
#if !defined(MAP_OVERRIDE_POD_WARS) && !defined(UPSCALED_MAP) && !defined(MAP_OVERRIDE_EVENT)
	var/mutable_appearance/ma = new(image('icons/misc/static.dmi', icon_state = "static"))
	ma.plane = PLANE_HUD
	ma.layer = 100
	ma.color = "#777777"
	ma.dir = pick(alldirs)
	ma.appearance_flags = TILE_BOUND | KEEP_APART | RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR
	ma.name = " "

	game_start_countdown?.update_status("Updating cameras...\n(Calculating...)")

	var/list/turf/cam_candidates = block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION))

	var/lastpct = 0
	var/thispct = 0
	var/donecount = 0

	for(var/turf/T as anything in cam_candidates) //ugh
		T.aiImage = new
		T.aiImage.appearance = ma
		T.aiImage.dir = pick(alldirs)
		T.aiImage.loc = T

		addAIImage(T.aiImage, "aiImage_\ref[T.aiImage]", low_priority=istype(T, /turf/space))

		donecount++
		thispct = round(donecount / length(cam_candidates) * 100)
		if (thispct != lastpct)
			lastpct = thispct
			game_start_countdown?.update_status("Updating cameras...\n[thispct]%")

		LAGCHECK(LAG_HIGH)

	game_start_countdown?.update_status("Updating cameras...\nCoverage...")
	src.update_all_emitters()
#endif

/**
 * Updates all emitters
 */
/datum/controller/camera_coverage/proc/update_all_emitters()
	src.update_emitters(by_type[/datum/component/camera_coverage_emitter])

/**
 * Given a list of turfs, updates their respective attached aiImage based on camera coverage
 */
/datum/controller/camera_coverage/proc/update_turfs(list/turf/turfs_to_update)
	if (!length(turfs_to_update))
		return
	for(var/turf/T as anything in turfs_to_update)
		if (global.explosions.exploding || ON_COOLDOWN(T, "camera_coverage_update", CAM_TURF_UPDATE_COOLDOWN))
			LAZYLISTADDUNIQUE(src.turf_update_queue, turfs_to_update)
		T.aiImage?.loc = length(T.camera_coverage_emitters) ? null : T

/**
 * Updates the camera coverage of a single emitter and returns the list of turfs that are requried to receive an update
 */
/datum/controller/camera_coverage/proc/update_emitter_internal(datum/component/camera_coverage_emitter/emitter)
	PRIVATE_PROC(TRUE)
	// This is a list of turfs that require an update.
	. = list()
#if defined(IM_REALLY_IN_A_FUCKING_HURRY_HERE) && !defined(SPACEMAN_DMM)
	return
#endif
	var/list/turf/prev_coverage = emitter.coverage ? emitter.coverage : list()
	var/list/turf/new_coverage = list()

	for (var/turf/T in (QDELETED(emitter) || !emitter.active) ? list() : view(emitter.range, emitter.parent))
		new_coverage += T

	var/list/turf/not_covered = prev_coverage - new_coverage
	var/list/turf/now_covered = new_coverage - prev_coverage

	// Remove this emitter from any turfs it was viewing
	for (var/turf/T as anything in not_covered)
		LAZYLISTREMOVE(T.camera_coverage_emitters, emitter)
		// Ugly, but a bunch of stuff uses the old /turf.cameras and requires it to be this exact type
		if (istype(emitter.parent, /obj/machinery/camera))
			LAZYLISTREMOVE(T.cameras, emitter.parent)

	// Add this turf to any turfs that it is now viewing
	for (var/turf/T as anything in now_covered)
		LAZYLISTADDUNIQUE(T.camera_coverage_emitters, emitter)
		// Ugly, but a bunch of stuff uses the old /turf.cameras and requires it to be this exact type
		if (istype(emitter.parent, /obj/machinery/camera))
			LAZYLISTADDUNIQUE(T.cameras, emitter.parent)

	// Gather our turfs that require updating
	. |= not_covered
	. |= now_covered

	// And finally we update our emitters coverage for the next time we check
	emitter.coverage = new_coverage

/**
 * Updates the camera coverage of a single emitter
 */
/datum/controller/camera_coverage/proc/update_emitter(datum/component/camera_coverage_emitter/emitter)
	src.update_emitters(list(emitter))

/**
 * Updates the camera coverage of multiple emitters
 */
/datum/controller/camera_coverage/proc/update_emitters(list/datum/component/camera_coverage_emitter/emitters)
	if (!length(emitters))
		return

	var/list/turf/turfs_to_update = list()

	for (var/datum/component/camera_coverage_emitter/emitter as anything in emitters)
		if (global.explosions.exploding || ON_COOLDOWN(emitter, "camera_coverage_update", CAM_UPDATE_COOLDOWN))
			LAZYLISTADDUNIQUE(src.emitter_update_queue, emitter)
			continue
		turfs_to_update |= src.update_emitter_internal(emitter)

	src.update_turfs(turfs_to_update)
