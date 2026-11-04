/datum/db_record/disease

/datum/db_record/disease/build_fields()
	return alist(
		"id"		= new /datum/record_field/string(src, "ID", "000000", @"[a-f0-9]{6}"),
		"name"		= new /datum/record_field/string(src, "Name"),
		"stages"	= new /datum/record_field/number(src, "Number Of Stages", 1, 1, INFINITY),
		"spread"	= new /datum/record_field/string(src, "Spread"),
		"cure"		= new /datum/record_field/string(src, "Possible Cure"),
		"affected"	= new /datum/record_field/string(src, "Affected Species"),
		"severity"	= new /datum/record_field/string(src, "Severity"),
		"notes"		= new /datum/record_field/string(src, "Notes"),
	)

/datum/db_record/disease/to_display_string()
	return src["name"]

/datum/db_record/disease/to_list_display_string()
	return src["name"]
