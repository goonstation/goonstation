/datum/db_record/disease

/datum/db_record/disease/build_fields()
	return alist(
		BUILD_FIELD("id",		/datum/record_field/string, "ID", "000000", @"[a-f0-9]{6}"),
		BUILD_FIELD("name",		/datum/record_field/string, "Name"),
		BUILD_FIELD("stages",	/datum/record_field/number, "Number Of Stages", 1, 1, INFINITY),
		BUILD_FIELD("spread",	/datum/record_field/string, "Spread"),
		BUILD_FIELD("cure",		/datum/record_field/string, "Possible Cure"),
		BUILD_FIELD("affected",	/datum/record_field/string, "Affected Species"),
		BUILD_FIELD("severity",	/datum/record_field/string, "Severity"),
		BUILD_FIELD("notes",	/datum/record_field/string, "Notes"),
	)

/datum/db_record/disease/to_display_string()
	return src["name"]

/datum/db_record/disease/to_list_display_string()
	return src["name"]
