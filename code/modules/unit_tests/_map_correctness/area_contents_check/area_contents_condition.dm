ABSTRACT_TYPE(/datum/area_contents_condition)
/datum/area_contents_condition
	/// The arguments passed to this condition on instantiation.
	var/list/arguments = null
	/// The output string of this condition, indicating expected and found instance counts.
	var/output = "Empty output. This shouldn't happen!"

/datum/area_contents_condition/New(...)
	src.arguments = args.Copy()
	. = ..()

/// Evaluates the condition and populates the `output` string. Returns `TRUE` on success.
/datum/area_contents_condition/proc/evaluate(alist/summed_contents)
	return


#define CONTENTS_LT(type, num_expected) new /datum/area_contents_condition/lt(type, num_expected)
/datum/area_contents_condition/lt/evaluate(alist/summed_contents)
	var/type = src.arguments[1]
	var/num_expected = src.arguments[2]
	var/num_found = summed_contents[type] || 0

	// If the amount found is less than the amount expected, pass the check.
	if (num_found < num_expected)
		. = TRUE

	src.output = "Less than [num_expected] instance\s of ([type]) [num_expected == 1 ? "was" : "were"] expected, [. ? "and" : "but"] [num_found] [num_found == 1 ? "was" : "were"] found."


#define CONTENTS_GT(type, num_expected) new /datum/area_contents_condition/gt(type, num_expected)
/datum/area_contents_condition/gt/evaluate(alist/summed_contents)
	var/type = src.arguments[1]
	var/num_expected = src.arguments[2]
	var/num_found = summed_contents[type] || 0

	// If the amount found is greater than the amount expected, pass the check.
	if (num_found > num_expected)
		. = TRUE

	src.output = "Greater than [num_expected] instance\s of ([type]) [num_expected == 1 ? "was" : "were"] expected, [. ? "and" : "but"] [num_found] [num_found == 1 ? "was" : "were"] found."


#define CONTENTS_EQ(type, num_expected) new /datum/area_contents_condition/eq(type, num_expected)
/datum/area_contents_condition/eq/evaluate(alist/summed_contents)
	var/type = src.arguments[1]
	var/num_expected = src.arguments[2]
	var/num_found = summed_contents[type] || 0

	// If the amount found is equal to the amount expected, pass the check.
	if (num_found == num_expected)
		. = TRUE

	src.output = "Exactly [num_expected] instance\s of ([type]) [num_expected == 1 ? "was" : "were"] expected, [. ? "and" : "but"] [num_found] [num_found == 1 ? "was" : "were"] found."


#define CONTENTS_OR new /datum/area_contents_condition/or
/datum/area_contents_condition/or/evaluate(alist/summed_contents)
	// Here, `arguments` is a list of expected contents lists, one of which must be satisfied.
	for (var/list/datum/area_contents_condition/expected_contents as anything in src.arguments)
		var/success = TRUE

		// All conditions inside of `expected_contents` must pass in order to pass the subcondition.
		for (var/datum/area_contents_condition/condition as anything in expected_contents)
			if (!condition.evaluate(summed_contents))
				success = FALSE

		// If the subcondition passed, pass the check.
		if (success)
			return TRUE

	src.output = "One of the following conditions was expected to be fulfilled:"
	for (var/i in 1 to length(src.arguments))
		// The use of a ZWSP (U+200B) enforces whitespace when the output is viewed from GitHub.
		var/prefix = "\n​ [i].) "
		for (var/datum/area_contents_condition/condition as anything in src.arguments[i])
			src.output += (prefix + condition.output)
			prefix = "\n​ ​ ​ & "
