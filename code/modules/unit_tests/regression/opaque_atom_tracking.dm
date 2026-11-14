/obj/opaque_tracking_blocker
	name = "opacity tracking test fixture"
	opacity = 1
	density = 1
	anchored = ANCHORED

/obj/opaque_tracking_blocker/transparent
	opacity = 0

/// Changes opacity from inside New() before ..() registers it with the turf
/obj/opaque_tracking_blocker/darkens_early
	opacity = 1

/obj/opaque_tracking_blocker/darkens_early/New()
	src.set_opacity(0)
	..()

/obj/opaque_tracking_blocker/brightens_early
	opacity = 0

/obj/opaque_tracking_blocker/brightens_early/New()
	src.set_opacity(1)
	..()

/**
 * `turf.opaque_atom_count` has to stay equal to the number of opaque movables on the turf, and camera coverage has to stay equal to what view() would return.
 * Both are maintained from /turf/Entered and /turf/Exited,
 * so anything that moves an atom without going through them desyncs lighting occlusion, LoS helpers, and AI camera coverage.
 */
/datum/unit_test/regression/opaque_atom_tracking

/// Coverage updates are debounced behind CAM_UPDATE_COOLDOWN, wait it out
/datum/unit_test/regression/opaque_atom_tracking/proc/settle()
	sleep(CAM_UPDATE_COOLDOWN + 1 DECI SECOND)
	var/list/queue = camera_coverage_controller.emitter_update_queue?.Copy()
	if (islist(queue))
		camera_coverage_controller.emitter_update_queue = null
		camera_coverage_controller.update_emitters(queue)
	queue = camera_coverage_controller.turf_update_queue?.Copy()
	if (islist(queue))
		camera_coverage_controller.turf_update_queue = null
		camera_coverage_controller.update_turfs(queue)

/// Returns FALSE and fails the test on the first mismatch.
/datum/unit_test/regression/opaque_atom_tracking/proc/verify(stage)
	src.settle()
	var/z = src.run_loc_floor_bottom_left.z

	for (var/turf/T as anything in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
		var/actual = 0
		for (var/atom/movable/AM in T)
			if (AM.opacity)
				actual++
		if (T.opaque_atom_count != actual)
			Fail("[stage]: ([T.x],[T.y]) opaque_atom_count is [T.opaque_atom_count] but [actual] opaque movables are on it")
			return FALSE

		for (var/datum/component/camera_coverage_emitter/emitter as anything in T.camera_coverage_emitters)
			if (!(T in emitter.coverage))
				Fail("[stage]: ([T.x],[T.y]) lists an emitter whose coverage does not contain it")
				return FALSE
		if (T.aiImage && T.aiImage.loc != (length(T.camera_coverage_emitters) ? null : T))
			Fail("[stage]: ([T.x],[T.y]) AI static overlay disagrees with its coverage")
			return FALSE

	for (var/datum/component/camera_coverage_emitter/emitter as anything in by_type[/datum/component/camera_coverage_emitter])
		var/atom/emitter_atom = emitter.parent
		var/list/turf/expected = list()
		if (!QDELETED(emitter) && emitter.active)
			for (var/turf/T in view(emitter.range, get_turf(emitter_atom)))
				expected += T

		if (length(emitter.coverage) != length(expected))
			Fail("[stage]: emitter at ([emitter_atom.x],[emitter_atom.y]) caches [length(emitter.coverage)] turfs, view() returns [length(expected)]")
			return FALSE
		for (var/turf/T as anything in expected)
			if (!(T in emitter.coverage))
				Fail("[stage]: ([T.x],[T.y]) is visible but missing from the cached coverage")
				return FALSE
			if (!(emitter in T.camera_coverage_emitters))
				Fail("[stage]: ([T.x],[T.y]) is covered but missing from its own camera_coverage_emitters")
				return FALSE

	return TRUE

/datum/unit_test/regression/opaque_atom_tracking/Run()
	var/z = src.run_loc_floor_bottom_left.z
	var/turf/blocking_turf = locate(6, 7, z)
	var/obj/machinery/camera/cam = src.allocate(/obj/machinery/camera, locate(6, 6, z))
	var/datum/component/camera_coverage_emitter/emitter = cam.GetComponent(/datum/component/camera_coverage_emitter)
	TEST_ASSERT(emitter, "the test camera has no camera coverage emitter")

	if (!src.verify("baseline"))
		return
	var/baseline = length(emitter.coverage)
	TEST_ASSERT(baseline > 8, "the camera only covers [baseline] turfs, too few to detect a change")

	// New() calls loc.Entered() itself rather than relying on BYOND
	var/obj/opaque_tracking_blocker/built = src.allocate(/obj/opaque_tracking_blocker, blocking_turf)
	if (!src.verify("built in place"))
		return
	var/blocked = length(emitter.coverage)
	TEST_ASSERT(blocked < baseline, "an opaque movable built in place did not shrink coverage")

	qdel(built)
	if (!src.verify("deleted in place"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "deleting it did not restore coverage")

	var/obj/opaque_tracking_blocker/transparent/clear = src.allocate(/obj/opaque_tracking_blocker/transparent, blocking_turf)
	if (!src.verify("transparent movable"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "a transparent movable changed coverage")
	qdel(clear)

	// The counter must not be touched before the turf has registered us, nor applied twice afterwards
	var/obj/opaque_tracking_blocker/darkens_early/darkens = src.allocate(/obj/opaque_tracking_blocker/darkens_early, blocking_turf)
	if (!src.verify("became transparent during New"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "an atom that went transparent during New still blocks")
	qdel(darkens)

	var/obj/opaque_tracking_blocker/brightens_early/brightens = src.allocate(/obj/opaque_tracking_blocker/brightens_early, blocking_turf)
	if (!src.verify("became opaque during New"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), blocked, "an atom that went opaque during New does not block")
	qdel(brightens)
	if (!src.verify("early opacity atoms removed"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "removing them did not restore coverage")

	// How smoke and most effects arrive
	var/obj/opaque_tracking_blocker/rover = new
	if (!src.verify("spawned at a null loc"))
		return
	rover.set_loc(blocking_turf)
	if (!src.verify("set_loc onto a turf"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), blocked, "set_loc onto a turf did not match building in place")

	rover.set_loc(locate(4, 4, z))
	if (!src.verify("set_loc turf to turf"))
		return

	var/obj/item/storage/box/container = src.allocate(/obj/item/storage/box, locate(3, 3, z))
	rover.set_loc(container)
	if (!src.verify("set_loc into a container"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "an opaque movable inside a container still blocks sight")

	rover.set_loc(blocking_turf)
	if (!src.verify("set_loc out of a container"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), blocked, "leaving the container did not restore blocking")

	rover.set_loc(null)
	if (!src.verify("set_loc to a null loc"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "set_loc(null) did not release the turf")
	qdel(rover)

	// step(), including a diagonal, which BYOND splits into two cardinal Move() calls.
	var/obj/effects/harmless_smoke/puff = new
	puff.set_loc(locate(2, 3, z))
	if (!src.verify("smoke spawned"))
		return
	step(puff, NORTH)
	if (!src.verify("smoke took a cardinal step"))
		return
	step(puff, NORTHEAST)
	if (!src.verify("smoke took a diagonal step"))
		return
	// Bounded: step_towards() returns without moving if the next tile is blocked
	for (var/i in 1 to 64)
		if (get_turf(puff) == blocking_turf)
			break
		step_towards(puff, blocking_turf)
	TEST_ASSERT_EQUAL(get_turf(puff), blocking_turf, "the smoke never reached the blocking turf")
	if (!src.verify("smoke walked into view"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), blocked, "smoke that step()ed into place disagrees with set_loc")

	qdel(puff)
	if (!src.verify("smoke died"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "smoke dying did not restore coverage")

	// Changing opacity in place goes through set_opacity(), not Entered/Exited.
	var/obj/machinery/door/airlock = src.allocate(/obj/machinery/door/airlock, blocking_turf)
	if (!src.verify("door closed"))
		return
	var/door_shut = length(emitter.coverage)
	airlock.set_opacity(0)
	if (!src.verify("door made transparent in place"))
		return
	TEST_ASSERT(length(emitter.coverage) > door_shut, "making a door transparent in place did not widen coverage")
	airlock.set_opacity(1)
	if (!src.verify("door made opaque in place"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), door_shut, "making it opaque again did not restore coverage")

	var/obj/opaque_tracking_blocker/stacked = src.allocate(/obj/opaque_tracking_blocker, blocking_turf)
	if (!src.verify("second opaque atom stacked"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), door_shut, "stacking a redundant opaque atom changed coverage")
	qdel(stacked)
	if (!src.verify("stacked atom removed"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), door_shut, "removing one of two blockers unblocked the turf early")
	qdel(airlock)
	if (!src.verify("last blocker removed"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "removing the last blocker did not restore coverage")

	// Spread smoke tiles get their opacity from the group update loop, not /obj/fluid/airborne/update_icon()
	var/turf/smoke_origin = locate(6, 9, z)
	smoke_origin.fluid_react_single("toxic_fart", 60, airborne = TRUE)
	var/datum/fluid_group/smoke_group = smoke_origin.active_airborne_liquid?.group
	TEST_ASSERT(smoke_group, "no airborne fluid group was created")
	smoke_group.update_once(4) // spread
	smoke_group.update_once() // member loop
	TEST_ASSERT(length(smoke_group.members) > 1, "the smoke did not spread")
	if (!src.verify("opaque smoke spread"))
		return
	smoke_group.evaporate()
	if (!src.verify("opaque smoke cleared"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "clearing the smoke did not restore coverage")

	// ReplaceWith has to carry turf opacity across the swap
	var/turf/victim = locate(6, 8, z)
	var/original_type = victim.type
	var/turf/wall = victim.ReplaceWith(/turf/simulated/wall, FALSE, TRUE, FALSE, TRUE)
	if (!src.verify("turf replaced with a wall"))
		return
	TEST_ASSERT(length(emitter.coverage) < baseline, "replacing a turf with a wall did not shrink coverage")
	wall.ReplaceWith(original_type, FALSE, TRUE, FALSE, TRUE)
	if (!src.verify("wall replaced with the original turf"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "restoring the turf did not restore coverage")

	cam.set_loc(locate(4, 4, z))
	if (!src.verify("camera moved"))
		return
	cam.set_loc(locate(6, 6, z))
	if (!src.verify("camera moved back"))
		return
	TEST_ASSERT_EQUAL(length(emitter.coverage), baseline, "moving the camera back did not restore coverage")
