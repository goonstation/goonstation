ABSTRACT_TYPE(/datum/map_correctness_check)
/datum/map_correctness_check
	/// The name of this check to display on check failure.
	var/check_name = null
	/// Whether this check should run while prefabs are being checked.
	var/check_prefabs = TRUE
	/// If non-empty, only run this check on the following maps.
	var/list/datum/map_settings/only_check_on = null
	/// If non-empty, skip this check on the following maps.
	var/list/datum/map_settings/skip_check_on = null

/datum/map_correctness_check/New()
	if (length(src.only_check_on) && length(src.skip_check_on))
		CRASH("Lists `only_check_on` and `skip_check_on` cannot both be non-empty.")

	. = ..()

/// Whether this check is elligible to be run.
/datum/map_correctness_check/proc/can_run_check()
#if (defined(PREFAB_CHECKING) || defined(RANDOM_ROOM_CHECKING))
	if (!src.check_prefabs)
		return FALSE
#endif

	if (length(src.only_check_on) && !istypes(global.map_settings, src.only_check_on))
		return FALSE

	if (length(src.skip_check_on) && istypes(global.map_settings, src.skip_check_on))
		return FALSE

	return TRUE

/// Run this map correctness check. Returns a list of strings indicating failure points.
/datum/map_correctness_check/proc/run_check()
	RETURN_TYPE(/list)
	return

/// Format the name, type, and position of an atom into a single string.
/datum/map_correctness_check/proc/format_position(atom/A)
	var/turf/T = get_turf(A)
	return "[A] ([A.type]) at ([T.x], [T.y], [T.z]) in [T.loc]"

/// Format a list of area types into a list in plain English as a string.
/datum/map_correctness_check/proc/area_list(list/area/area_list, and_text = " and ")
	var/list/text_list = list()
	for (var/area/A as anything in area_list)
		text_list += "([A])"

	return global.english_list(text_list, and_text = and_text)
