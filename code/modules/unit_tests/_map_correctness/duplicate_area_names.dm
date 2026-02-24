/datum/map_correctness_check/duplicate_area_names
	check_name = "Duplicate Area Names"

/datum/map_correctness_check/duplicate_area_names/run_check()
	var/list/area_names = list()
	for (var/area/A in world)
		if (istype(A, /area/shuttle/merchant_shuttle))
			continue

		area_names[A.name] ||= list()
		area_names[A.name] |= A.type

	var/list/duplicates = list()
	for (var/name in area_names)
		if (length(area_names[name]) > 1)
			duplicates += name

	if (length(duplicates))
		. = list()

		for (var/name in duplicates)
			. += "\"[name || "***EMPTY STRING***"]\": [english_list(area_names[name])]"
