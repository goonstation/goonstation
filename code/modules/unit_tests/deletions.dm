/// This is for regression tests of deletions that used to runtime.
/// This would ideally be replaced by Del The World, unit testing every single deletion.
/datum/unit_test/deletion_regressions

/datum/unit_test/deletion_regressions/Run()

#define UNIT_TEST_FULL_SUITE
#if defined(UNIT_TEST_FULL_SUITE)
/// This loops through all objects creates them and then deletes them
/// MUST BE OPTED INTO AS THIS TAKES 12min
/datum/unit_test/deletion_and_creation
	var/prev_runtimes = 0
	var/checks = 0
	var/list/ignore_hash = list()
	var/list/crash_hash = list()

/datum/unit_test/deletion_and_creation/Run()
	/// These are types that are problematic not intended to be used outside of map content
	var/list/ignore_list = list(/obj/landmark/spawner, /obj/landmark/spawner/inside)
	ignore_list += list(/obj/noticeboard/persistent)
	ignore_list += typesof(/obj/effects/ydrone_summon) // this will thrash everything nearby.... good "destructive" test
	ignore_list += typesof(/obj/machinery/conveyor)

	for(var/type in ignore_list)
		ignore_hash[type] = TRUE

	/// These types are expected to crash due to error handling
	var/list/expected_crash = list(/obj/wingrille_spawn, /obj/item/aiModule/random=20)
	for(var/crash_type in expected_crash)
		crash_hash[crash_type] = expected_crash[crash_type] || 1

	for(var/obj/obj_type as anything in concrete_typesof(/obj))
		if(ignore_hash[obj_type])
			continue
		if(initial(obj_type.event_handler_flags) & USE_HASENTERED)
			var/obj/O = new obj_type(run_loc_floor_top_right)
			qdel(O)
		else
			allocate(obj_type)
		check_runtimes(obj_type, FALSE)

	for(var/mob/mob_type in concrete_typesof(/mob))
		allocate(mob_type)
		check_runtimes(mob_type, FALSE)

	var/old_turf = src.run_loc_floor_bottom_left.type
	var/turf/prev = src.run_loc_floor_bottom_left
	for(var/turf/turf_types in concrete_typesof(/turf))
		var/obj/T = new turf_types(prev)
		prev = T
	prev = new old_turf(prev)

/datum/unit_test/deletion_and_creation/proc/check_runtimes(type, deletion)
	/// Type is expected to crash due to incorrect object generation, adjust expected
	if(crash_hash[type])
		prev_runtimes += crash_hash[type]

	if(prev_runtimes != runtime_count)

		for (var/idx in max(prev_runtimes,1) to runtime_count)
			var/list/details = runtimeDetails["[idx]"]
			if(length(details))
				var/timestamp = details["seen"]
				var/file = details["file"]
				var/line = details["line"]
				var/name = details["name"]
				text2file("\[[timestamp]\] [file],[line]: [name]", "errors.log")

		var/last_runtime_count = prev_runtimes
		prev_runtimes = runtime_count
		TEST_ASSERT_EQUAL(last_runtime_count, runtime_count, "[type] generated runtime on [deletion ? "qdel()" : "New()"]")

	checks++
	if(checks % 25 == 0)
		sleep(0)
		LAGCHECK(LAG_LOW)
#endif


