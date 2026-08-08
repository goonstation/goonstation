#ifdef CI_RUNTIME_CHECKING
	#define CI_LIST list()
#else
	#define CI_LIST null
#endif

/// Namespace for continuous integration (CI) related data.
CREATE_NAMESPACE(CI)

/// Format the name, type, and position of an atom into a single string.
ADD_TO_NAMESPACE(CI)(proc/format_position(atom/A, capitalise = TRUE))
	var/turf/T = get_turf(A)
	if (capitalise)
		return "\The [A.name] ([A.type]) at ([T.x], [T.y], [T.z]) in [T.loc]"
	else
		return "\the [A.name] ([A.type]) at ([T.x], [T.y], [T.z]) in [T.loc]"

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


//------------ Mapping Helper Colours ------------//
/// Default colours for mapping helpers.
CREATE_NAMESPACE(CI, COL)

ADD_TO_NAMESPACE(CI, COL)(var/const/CARGO = "#f7e43d")
ADD_TO_NAMESPACE(CI, COL)(var/const/COMMAND = "#00783c")
ADD_TO_NAMESPACE(CI, COL)(var/const/ENGINEERING = "#f7af3d")
ADD_TO_NAMESPACE(CI, COL)(var/const/MAINTENANCE = "#e5ff32")
ADD_TO_NAMESPACE(CI, COL)(var/const/MEDICAL = "#3daff7")
ADD_TO_NAMESPACE(CI, COL)(var/const/MORGUE = "#002135")
ADD_TO_NAMESPACE(CI, COL)(var/const/RESEARCH = "#b23df7")
ADD_TO_NAMESPACE(CI, COL)(var/const/TOXINS = "#a3f73d")
ADD_TO_NAMESPACE(CI, COL)(var/const/SECURITY = "#f73d3d")
ADD_TO_NAMESPACE(CI, COL)(var/const/SPECIAL = "#ffa135")


#undef CI_LIST
