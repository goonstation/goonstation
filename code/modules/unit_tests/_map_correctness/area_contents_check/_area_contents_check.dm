ABSTRACT_TYPE(/datum/map_correctness_check/area_contents)
/datum/map_correctness_check/area_contents
	check_prefabs = FALSE
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
	 *	Elements of this list should always use the `CONTENTS_LT`, `CONTENTS_GT`, `CONTENTS_EQ` or `CONTENTS_OR` macros.
	 */
	var/list/datum/area_contents_condition/expected_contents = list()

/datum/map_correctness_check/area_contents/run_check()
	var/list/area_check_results = list()

	var/alist/summed_contents = alist()
	for (var/target_area_type in src.target_areas)
		for (var/area/A as anything in global.by_type[target_area_type])
			for (var/type in A.mapload_contents)
				summed_contents[type] ||= 0
				summed_contents[type] += A.mapload_contents[type]

	for (var/datum/area_contents_condition/condition as anything in src.expected_contents)
		if (!condition.evaluate(summed_contents))
			area_check_results += condition.output

	if (length(area_check_results))
		. = list()
		. += "The following objects were expected in [src.area_list(src.target_areas, and_text = " or ")]:"
		. += area_check_results


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
