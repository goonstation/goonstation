/datum/db_record/personnel/security

/datum/db_record/personnel/security/build_fields()
	return alist(
		"id"		= new /datum/record_field/string(src, "ID", "000000", @"[a-f0-9]{6}"),
		"name"		= new /datum/record_field/string(src, "Name", "New Record"),
		"criminal"	= new /datum/record_field/choice/criminal(src, "Criminal Status"),
		"sec_flag"	= new /datum/record_field/string/sec_flag(src, "SecHUD Flag"),
		"citations"	= new /datum/record_field/record_list(src, "Citations"),
		"mi_crim"	= new /datum/record_field/string(src, "Minor Crimes", "None"),
		"mi_crim_d"	= new /datum/record_field/string(src, "Details", "No minor crime convictions."),
		"ma_crim"	= new /datum/record_field/string(src, "Major Crimes", "None"),
		"ma_crim_d"	= new /datum/record_field/string(src, "Details", "No major crime convictions."),
		"notes"		= new /datum/record_field/string(src, "Important Notes", "No notes."),
	)

/datum/db_record/personnel/security/New(source)
	. = ..()

	var/datum/record_field/record_list/citations = src.get_field_datum("citations")
	citations.record_group = new /datum/db_record_group/citation/record(src)

/datum/db_record/personnel/security/init_from_human(mob/living/carbon/human/H)
	src["id"] = H.datacore_id
	src["name"] = H.real_name

	if (H.traitHolder?.hasTrait("training_clown"))
		src["criminal"] = SECURITY::ARREST::STATE::CLOWN
		src["mi_crim"] = "Clown"

	if (H.client?.preferences?.security_note)
		src["notes"] = H.client?.preferences?.security_note
