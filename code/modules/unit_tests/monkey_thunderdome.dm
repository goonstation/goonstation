// Monkey hell test - throws a bunch of dangerous armed angery monkeys into a ring and hopes they don't cause runtimes
/datum/unit_test/monkey_thunderdome

/datum/unit_test/monkey_thunderdome/Run()
	var/starting_runtimes = runtime_count
	var/list/turf/spawn_turfs = block(run_loc_floor_bottom_left, run_loc_floor_top_right)
	for (var/i in 1 to 40)
		var/mob/living/carbon/human/npc/monkey/angry/testing/monke = new(pick(spawn_turfs))
		monke.mob_flags |= HEAVYWEIGHT_AI_MOB // gotta go fast
	LAGCHECK(LAG_HIGH)
	sleep(15 SECONDS)
	var/caused_runtimes = runtime_count - starting_runtimes
	if (caused_runtimes)
		Fail("Angery monkeys caused [caused_runtimes] runtimes")
