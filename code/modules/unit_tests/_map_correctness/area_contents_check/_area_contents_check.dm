#define CONTENTS_LT(type, num_expected) type = CALLBACK(null, PROC_REF(lt), type, num_expected)
#define CONTENTS_GT(type, num_expected) type = CALLBACK(null, PROC_REF(gt), type, num_expected)
#define CONTENTS_EQ(type, num_expected) type = CALLBACK(null, PROC_REF(eq), type, num_expected)

ABSTRACT_TYPE(/datum/map_correctness_check/area_contents)
/datum/map_correctness_check/area_contents
	/**
	 *	The areas that should be checked for the expected contents. All subtypes of target areas are also considered. \
	 *	The union of the contents of the target areas (and their subtypes) is checked, so the check can be thought of as
	 *	asking `"Is object /atom/X in /area/A OR /area/B?"`. \
	 *	Intersection checks, i.e. `"Is object /atom/X in /area/A AND /area/B?"`, may be constructed using multiple checks.
	 */
	var/list/area/target_areas = list()
	/**
	 *	The expected contents of the target area. Subtypes of atoms are counted towards the total count for an atom in an
	 *	area, so instances of `/atom/X/Y` would count towards the total count of `/atom/X`. \
	 *	Elements of this list should always use the `CONTENTS_LT`, `CONTENTS_GT`, or `CONTENTS_EQ` macros.
	 */
	var/list/datum/callback/expected_contents = list()

/datum/map_correctness_check/area_contents/New()
	// Set the calling object of the callback here, as `src` cannot be used statically.
	for (var/type in src.expected_contents)
		src.expected_contents[type].object = src

	. = ..()

/datum/map_correctness_check/area_contents/run_check()
	var/list/area_check_results = list()

	var/alist/summed_contents = alist()
	for (var/target_area_type in src.target_areas)
		for (var/area/A as anything in global.by_type[target_area_type])
			for (var/type in A.mapload_contents)
				summed_contents[type] ||= 0
				summed_contents[type] += A.mapload_contents[type]

	for (var/type in src.expected_contents)
		var/num_found = summed_contents[type] || 0
		var/result = src.expected_contents[type].Invoke(num_found)

		if (result)
			area_check_results += result

	if (length(area_check_results))
		. = list()
		. += "The following objects were expected in [src.area_list(src.target_areas, and_text = " or ")]:"
		. += area_check_results

/// The check used to determine if the number of instances of a type found is less than the number expected.
/datum/map_correctness_check/area_contents/proc/lt(type, num_expected, num_found)
	// If the amount found is less than the amount expected, pass the check.
	if (num_found < num_expected)
		return

	// Otherwise return an error message.
	return "Less than [num_expected] instance\s of ([type]) [num_expected == 1 ? "was" : "were"] expected, but [num_found] [num_found == 1 ? "was" : "were"] found."

/// The check used to determine if the number of instances of a type found is greater than the number expected.
/datum/map_correctness_check/area_contents/proc/gt(type, num_expected, num_found)
	// If the amount found is greater than the amount expected, pass the check.
	if (num_found > num_expected)
		return

	// Otherwise return an error message.
	return "Greater than [num_expected] instance\s of ([type]) [num_expected == 1 ? "was" : "were"] expected, but [num_found] [num_found == 1 ? "was" : "were"] found."

/// The check used to determine if the number of instances of a type found is equal to the number expected.
/datum/map_correctness_check/area_contents/proc/eq(type, num_expected, num_found)
	// If the amount found is equal to the amount expected, pass the check.
	if (num_found == num_expected)
		return

	// Otherwise return an error message.
	return "Exactly [num_expected] instance\s of ([type]) [num_expected == 1 ? "was" : "were"] expected, but [num_found] [num_found == 1 ? "was" : "were"] found."


/// A list of atoms types instantiated in this area during mapload and their associated counts. Only populated if `CI_RUNTIME_CHECKING` is enabled.
/area/var/alist/mapload_contents = null

#ifdef CI_RUNTIME_CHECKING

/area/New()
	src.mapload_contents = alist()

	var/area/type = src.type
	while (type != /area)
		global.by_type[type] ||= list()
		global.by_type[type][src] = TRUE
		type = type::parent_type

	. = ..()


/atom/New()
	. = ..()

	var/area/A = get_area(src)
	if (!A)
		return

	var/atom/type = src.type
	while (type != /atom)
		A.mapload_contents[type] ||= 0
		A.mapload_contents[type] += 1
		type = type::parent_type

#endif
