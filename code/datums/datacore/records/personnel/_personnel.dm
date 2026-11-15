ABSTRACT_TYPE(/datum/db_record/personnel)
/datum/db_record/personnel

/datum/db_record/personnel/New(source)
	. = ..()

	if (ishuman(source))
		src.init_from_human(source)
	else if (istype(source, /datum/db_record/personnel/general))
		src.init_from_record(source)

/datum/db_record/personnel/to_display_string()
	var/datum/db_record/personnel/general/record = global.data_core.get_general_record(id = src["id"])
	if (istype(record))
		return record.to_display_string()

	return "ERR: HEADLESS RECORD"

/datum/db_record/personnel/to_list_display_string()
	var/datum/db_record/personnel/general/record = global.data_core.get_general_record(id = src["id"])
	if (istype(record))
		return record.to_list_display_string()

	return "ERR: HEADLESS RECORD"

/// Initialise the values of this personnel record's fields from a human.
/datum/db_record/personnel/proc/init_from_human(mob/living/carbon/human/H)
	return

/// Initialise the values of this personnel record's fields from a general record.
/datum/db_record/personnel/proc/init_from_record(datum/db_record/personnel/general/G)
	src["id"] = G["id"]

/// Update the values of this personnel record's fields from a scan of a human.
/datum/db_record/personnel/proc/update_from_scan(mob/living/carbon/human/H)
	return
