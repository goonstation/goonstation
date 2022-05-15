/datum/unit_test/duplicate_area_names

/datum/unit_test/duplicate_area_names/Run()
	var/list/names = list()
	var/area/A
	for (var/AT in concrete_typesof(/area))
		A = new AT
		if (!names[A.name])
			names[A.name] = list()
		names[A.name] += AT
		qdel(A)

	var/list/dupes = list()
	for (var/name in names)
		if (names[name] > 1)
			dupes += name

	if (length(dupes))
		// Build descriptive failure message
		var/failmsg = "The following area names are duplicated: \n"
		for (var/dupe in dupes)
			failmsg += "\"[dupe || "***EMPTY STRING***"]\": [english_list(names[dupe])]"

		Fail("The following area names are duplicated: [english_list(dupes)]")
