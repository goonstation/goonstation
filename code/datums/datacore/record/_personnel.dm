/datum/db_record/personnel
	fields = alist(
		"id"	= new /datum/record_field/string("000000", @"[a-f0-9]{6}"),
		"name"	= new /datum/record_field/string("Name", "New Record"),
	)

/datum/db_record/personnel/New(source)
	. = ..()

	if (ishuman(source))
		src.init_from_human(source)
	else if (istype(source, /datum/db_record/personnel/general))
		src.init_from_record(source)

/datum/db_record/personnel/to_display_string()
	return "[src["id"]]: [src["name"]]"

/// Initialise the values of this personnel record's fields from a human.
/datum/db_record/personnel/proc/init_from_human(mob/living/carbon/human/H)
	return

/// Initialise the values of this personnel record's fields from a general record.
/datum/db_record/personnel/proc/init_from_record(datum/db_record/personnel/general/G)
	src["id"] = G["id"]
	src["name"] = G["name"]
