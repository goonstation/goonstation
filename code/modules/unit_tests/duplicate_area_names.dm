/datum/unit_test/duplicate_area_names

/datum/unit_test/duplicate_area_names/Run()
	var/list/names = list()
	var/area/A
	for (var/AT in concrete_typesof(/area))
		A = new AT
		if (!names[A.name])
			names[A.name] = 0
		names[A.name] += 1
		qdel(A)

	var/list/dupes = list()
	for (var/name in names)
		if (names[name] > 1)
			dupes += name

	if (length(dupes))
		Fail("The following area names are duplicated: [english_list(dupes)]")
