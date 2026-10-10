/datum/db_record/citation
	fields = alist(
		"id" 		= new /datum/record_field/string("ID", "000000", @"[a-f0-9]{6}"),
		"time"		= new /datum/record_field/string("Time", "00:00:00"),
		"type"		= new /datum/record_field/choice("Type", "TICKET", list("TICKET", "FINE")),
		"target"	= new /datum/record_field/string("Target", "Unknown"),
	)

/datum/db_record/citation/to_display_string()
	return src["id"] + ": " + src["target"]
