#ifdef CI_RUNTIME_CHECKING

// Not quite a unit test but achieves the same goal. Ran for each map unlike actual unit tests.
/proc/check_map_correctness()
	var/success = TRUE
	var/log_text = "Map Correctness Checks Failed!"

	for (var/T in concrete_typesof(/datum/map_correctness_check))
		var/datum/map_correctness_check/map_check = new T()

		#if (defined(PREFAB_CHECKING) || defined(RANDOM_ROOM_CHECKING))
		if (!map_check.check_prefabs)
			continue
		#endif

		var/list/map_check_result = map_check.run_check()
		if (length(map_check_result))
			success = FALSE

			// The use of a ZWSP (U+200B) enforces empty lines when the output is viewed from GitHub.
			log_text += "\n​\n# " + map_check.check_name + "\n"
			log_text += map_check_result.Join("\n")

	if (!success)
		CRASH(log_text)

#endif


#ifdef CI_RUNTIME_CHECKING
	#define SET_UP_CI_TRACKING(TYPE) \
		TYPE/New() { \
			. = ..(); \
			START_TRACKING; \
		} \
		TYPE/disposing() { \
			STOP_TRACKING; \
			. = ..(); \
		}
#else
	#define SET_UP_CI_TRACKING(TYPE)
#endif
