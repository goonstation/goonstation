/*

Usage:
Override /Run() to run your test code

Call Fail() to fail the test (You should specify a reason)

You may use /New() and /Destroy() for setup/teardown respectively

You can use the run_loc_floor_bottom_left and run_loc_floor_top_right to get turfs for testing

Based on Unit Test Framework by: Cyberboss

*/


#define LANDMARK_BOTTOM_LEFT "bottom_left"
#define LANDMARK_TOP_RIGHT "top_right"

var/global/datum/unit_test_controller/unit_tests = new()
/datum/unit_test_controller
	var/datum/unit_test/current_test
	var/failed_any_test = FALSE
	var/test_log

/datum/unit_test_controller/proc/log_test(text)
	if(src.test_log)
		src.test_log << "\[[time2text(world.timeofday,"hh:mm:ss")]]: [text]"
	world.log << text

/datum/unit_test_controller/proc/run_tests()
	rand_seed(69420)
	LAGCHECK(LAG_HIGH)

	var/tests_to_run = childrentypesof(/datum/unit_test)
	for (var/_test_to_run in tests_to_run)
		var/datum/unit_test/test_to_run = _test_to_run
		if (initial(test_to_run.focus))
			tests_to_run = list(test_to_run)
			break

	var/list/test_results = list()

	for(var/I in tests_to_run)
		var/datum/unit_test/test = new I
		LAGCHECK(LAG_HIGH)

		src.current_test = test
		var/duration = TIME

		test.Run()

		duration = TIME - duration
		src.current_test = null
		src.failed_any_test |= !test.succeeded

		var/list/log_entry = list("[test.succeeded ? "PASS" : "FAIL"]: [I] [duration / 10]s")
		var/list/fail_reasons = test.fail_reasons

		for(var/J in 1 to length(fail_reasons))
			log_entry += "\tREASON #[J]: [fail_reasons[J]]"
		var/message = log_entry.Join("\n")
		log_test(message)

		test_results[I] = list("status" = test.succeeded ? UNIT_TEST_PASSED : UNIT_TEST_FAILED, "message" = message, "name" = I)

		qdel(test)
		LAGCHECK(LAG_HIGH)

	var/file_name = "data/unit_tests.json"
	fdel(file_name)
	file(file_name) << json_encode(test_results)

	//Fail Automaton
	if(src.failed_any_test)
		for(var/test in test_results)
			if(test_results[test]["status"]==UNIT_TEST_FAILED)
				text2file("[test_results[test]["message"]]", "errors.log")

	//We done, lets bail when mapSwitcher awakens
	while(!mapSwitcher)
		sleep(1 DECI SECOND)
	Reboot_server()

/datum/unit_test
	//Bit of metadata for the future maybe
	var/list/procs_tested

	/// The bottom left floor turf of the testing zone
	var/turf/run_loc_floor_bottom_left

	/// The top right floor turf of the testing zone
	var/turf/run_loc_floor_top_right

	//internal shit
	var/focus = FALSE
	var/succeeded = TRUE
	var/list/allocated
	var/list/fail_reasons

/datum/unit_test/New()
	..()
	allocated = new
	if(landmarks[LANDMARK_BOTTOM_LEFT])
		run_loc_floor_bottom_left = landmarks[LANDMARK_BOTTOM_LEFT][1]
	if(landmarks[LANDMARK_TOP_RIGHT])
		run_loc_floor_top_right = landmarks[LANDMARK_TOP_RIGHT][1]

	TEST_ASSERT(isturf(run_loc_floor_bottom_left), "run_loc_floor_bottom_left was not a floor ([run_loc_floor_bottom_left])")
	TEST_ASSERT(isturf(run_loc_floor_top_right), "run_loc_floor_top_right was not a floor ([run_loc_floor_top_right])")

/datum/unit_test/disposing()
	for(var/elem in allocated)
		qdel(elem)
	allocated.len = 0

	// clear the test area
	for (var/turf/turf in block(locate(1, 1, run_loc_floor_bottom_left.z), locate(world.maxx, world.maxy, run_loc_floor_bottom_left.z)))
		for (var/content in turf.contents)
			if (istype(content, /obj/landmark))
				continue
			qdel(content)
	return ..()

/datum/unit_test/proc/Run()
	Fail("Run() called parent or not implemented")

/datum/unit_test/proc/Fail(reason = "No reason")
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYLISTADD(fail_reasons, reason)

/// Allocates an instance of the provided type, and places it somewhere in an available loc
/// Instances allocated through this proc will be destroyed when the test is over
/datum/unit_test/proc/allocate(type, ...)
	var/list/arguments = args.Copy(2)
	if (!length(arguments))
		arguments = list(run_loc_floor_bottom_left)
	else if (arguments[1] == null)
		arguments[1] = run_loc_floor_bottom_left
	var/instance = new type(arglist(arguments))
	allocated += instance
	return instance

/area/testroom
/obj/landmark/unit_test_top_right
	name = LANDMARK_TOP_RIGHT

/obj/landmark/unit_test_bottom_left
	name = LANDMARK_BOTTOM_LEFT


#undef LANDMARK_BOTTOM_LEFT
#undef LANDMARK_TOP_RIGHT
