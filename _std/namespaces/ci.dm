#ifdef CI_RUNTIME_CHECKING
	#define CI_LIST list()
#else
	#define CI_LIST null
#endif

/// Namespace for continuous integration (CI) related data.
CREATE_NAMESPACE(CI)

/// Prefabs currently loaded: `list(path, min_x, min_y, max_x, max_y, z)`
ADD_TO_NAMESPACE(CI)(var/list/placed_prefabs = CI_LIST)

/// Format a turf's position and the prefab/area it's in into a single string.
ADD_TO_NAMESPACE(CI)(proc/format_location(turf/T))
	for (var/list/prefab as anything in CI.placed_prefabs)
		if (T.z == prefab[6] && T.x >= prefab[2] && T.y >= prefab[3] && T.x <= prefab[4] && T.y <= prefab[5])
			return "([T.x], [T.y], [T.z]) in [T.loc] in prefab [prefab[1]]"

	return "([T.x], [T.y], [T.z]) in [T.loc]"

/// Format the name, type, and position of an atom into a single string.
ADD_TO_NAMESPACE(CI)(proc/format_position(atom/A, capitalise = TRUE))
	var/turf/T = get_turf(A)
	if (capitalise)
		return "\The [A.name] ([A.type]) at [CI.format_location(T)]"
	else
		return "\the [A.name] ([A.type]) at [CI.format_location(T)]"

/// Format a list of types into a list in plain English as a string.
ADD_TO_NAMESPACE(CI)(proc/type_list(list/area/type_list, and_text = " and "))
	var/list/text_list = list()
	for (var/type as anything in type_list)
		text_list += "([type])"

	return global.english_list(text_list, and_text = and_text)

/// Format a list of area types into a list in plain English as a string.
ADD_TO_NAMESPACE(CI)(proc/area_list(list/area/area_list, and_text = " and "))
	var/list/text_list = list()
	for (var/area/A as anything in area_list)
		text_list += "([A])"

	return global.english_list(text_list, and_text = and_text)


//------------ Error Logging ------------//
/// CI errors encountered before CI unit and map correctness checks have had a chance to run.
CREATE_NAMESPACE(CI, ERRORS)

/// Misconfigured mail chutes.
ADD_TO_NAMESPACE(CI, ERRORS)(var/list/mail_chutes = CI_LIST)
/// Misconfigured mail junctions.
ADD_TO_NAMESPACE(CI, ERRORS)(var/list/mail_junctions = CI_LIST)
/// Misconfigured mapping helpers.
ADD_TO_NAMESPACE(CI, ERRORS)(var/list/mapping_helpers = CI_LIST)


#undef CI_LIST
