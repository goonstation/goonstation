/// Every case here adds an opaque thing near a light, takes it away again, and expects lighting to be back where it started.
/datum/unit_test/regression/opaque_lighting

/// Every turf's red luminance on the test z
/datum/unit_test/regression/opaque_lighting/proc/luminance()
	. = list()
	var/z = src.run_loc_floor_bottom_left.z
	for (var/turf/T as anything in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
		. += T.RL_LumR

/datum/unit_test/regression/opaque_lighting/proc/drifted(list/before)
	var/list/now = src.luminance()
	for (var/i in 1 to length(before))
		if (abs(before[i] - now[i]) >= 0.001)
			return TRUE
	return FALSE

/datum/unit_test/regression/opaque_lighting/Run()
	var/z = src.run_loc_floor_bottom_left.z
	var/turf/spot = locate(6, 7, z)
	var/datum/light/point/lamp = src.allocate(/datum/light/point, 6.5, 5.5, z)
	lamp.set_brightness(3) // bright enough to reach past the spot's shadow
	lamp.enable()
	var/list/lit = src.luminance()
	var/turf/beyond = locate(6, 10, z)
	var/beyond_lit = beyond.RL_LumR
	TEST_ASSERT(beyond_lit > 0, "the test light does not reach past the spot")

	for (var/blocker_type in list(/obj/opaque_tracking_blocker, /obj/effects/harmless_smoke))
		qdel(new blocker_type(spot))
		TEST_ASSERT(!src.drifted(lit), "building and removing [blocker_type] left lighting changed")

	var/obj/opaque_tracking_blocker/walker = new(locate(5, 7, z))
	step(walker, EAST)
	TEST_ASSERT_EQUAL(get_turf(walker), spot, "the blocker did not step onto the spot")
	qdel(walker)
	TEST_ASSERT(!src.drifted(lit), "an opaque atom step()ping left lighting changed")

	// How smoke puffs spawn
	var/obj/opaque_tracking_blocker/dropped = new
	dropped.set_loc(spot)
	qdel(dropped)
	TEST_ASSERT(!src.drifted(lit), "an opaque atom set_loc()ed in from nullspace left lighting changed")

	var/obj/item/storage/box/box = new(locate(3, 3, z))
	var/obj/opaque_tracking_blocker/boxed = new(spot)
	boxed.set_loc(box)
	TEST_ASSERT(!src.drifted(lit), "an opaque atom put in a container still shadows its old turf")
	boxed.set_loc(spot)
	qdel(boxed)
	qdel(box)
	TEST_ASSERT(!src.drifted(lit), "an opaque atom taken out of a container left lighting changed")

	// Airborne reagent smoke, spread tiles only get opacity from the group update loop
	var/turf/smoke_origin = locate(6, 8, z)
	smoke_origin.fluid_react_single("toxic_fart", 60, airborne = TRUE)
	var/datum/fluid_group/smoke_group = smoke_origin.active_airborne_liquid?.group
	TEST_ASSERT(smoke_group, "no airborne fluid group was created")
	smoke_group.update_once(4) // spread
	smoke_group.update_once() // member loop
	TEST_ASSERT(length(smoke_group.members) > 1, "the smoke did not spread")
	smoke_group.evaporate()
	TEST_ASSERT(!src.drifted(lit), "opaque reagent smoke left lighting changed")

	// Lights bleed one tile into shadows, so a lone wall's shadow gets filled in, build a whole line
	// zewaka todo: turfs don't relight on opacity changes yet, assert the walls shadowed once they do
	var/original_type = spot.type
	for (var/turf/T as anything in block(locate(2, 7, z), locate(10, 7, z)))
		T.ReplaceWith(/turf/simulated/wall, FALSE, TRUE, FALSE, TRUE)
	for (var/turf/T as anything in block(locate(2, 7, z), locate(10, 7, z)))
		T.ReplaceWith(original_type, FALSE, TRUE, FALSE, TRUE)
	TEST_ASSERT(!src.drifted(lit), "ReplaceWith() to a wall and back left lighting changed")
