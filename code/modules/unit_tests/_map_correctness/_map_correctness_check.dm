ABSTRACT_TYPE(/datum/map_correctness_check)
/datum/map_correctness_check
	var/check_name = null
	var/check_prefabs = TRUE

/// Run this map correctness check. Returns a list of strings indicating failure points.
/datum/map_correctness_check/proc/run_check()
	RETURN_TYPE(/list)
	return

/// Format the name, type, and position of an atom into a single string.
/datum/map_correctness_check/proc/format_position(atom/A)
	var/turf/T = get_turf(A)
	return "[A] ([A.type]) at ([T.x], [T.y], [T.z]) in [T.loc]"
