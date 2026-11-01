/datum/unit_test/explosion_test

/datum/unit_test/explosion_test/Run()
	var/list/turf/spawn_turfs = block(run_loc_floor_bottom_left, run_loc_floor_top_right)

	// Spawn random items
	for(var/i in 1 to 10)
		new /obj/random_item_spawner/tools_w_igloves(pick(spawn_turfs))

	var/turf/test_turf = locate(run_loc_floor_bottom_left.x+3,run_loc_floor_bottom_left.y+3,run_loc_floor_bottom_left.z)
	// Spawn test mob
	var/mob/living/carbon/human/H = new(test_turf)

	var/oldhealth = H.health
	// Cause explosion
	explosion(
		test_turf,
		test_turf,
		5,
		5,
		5,
		5
	)

	SPAWN(0.2 SECONDS)
		// Assert mob took damage
		if(H?.health >= oldhealth)
			Fail("Mob took no damage from explosion")
