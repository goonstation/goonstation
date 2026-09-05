/datum/db_record/personnel
	fields = list(
		"id"	= null,
		"name"	= null,
	)

/datum/db_record/personnel/New(source)
	. = ..()

	if (ishuman(source))
		src.init_from_human(source)
	else if (istype(source, /datum/db_record/personnel/general))
		src.init_from_record(source)

/// Initialise the values of this personnel record's fields from a human.
/datum/db_record/personnel/proc/init_from_human(mob/living/carbon/human/H)
	return

/// Initialise the values of this personnel record's fields from a general record.
/datum/db_record/personnel/proc/init_from_record(datum/db_record/personnel/general/G)
	src["id"] = G["id"]
	src["name"] = G["name"]
