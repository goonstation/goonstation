/datum/db_record/disease
	fields = alist(
		"id"		= new /datum/record_field/string("000000", @"[a-f0-9]{6}"),
		"name"		= new /datum/record_field/string("Name"),
		"stages"	= new /datum/record_field/number("Number Of Stages", 1, 1, INFINITY),
		"spread"	= new /datum/record_field/string("Spread"),
		"cure"		= new /datum/record_field/string("Possible Cure"),
		"affected"	= new /datum/record_field/string("Affected Species"),
		"severity"	= new /datum/record_field/string("Severity"),
		"notes"		= new /datum/record_field/string("Notes"),
	)

/datum/db_record/disease/to_display_string()
	return src["name"]
