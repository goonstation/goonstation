/datum/db_record/personnel/security
	fields = alist(
		"id"		= new /datum/record_field/string("ID", "000000", @"[a-f0-9]{6}"),
		"name"		= new /datum/record_field/string("Name", "New Record"),
		"criminal"	= new /datum/record_field/choice("Criminal Status", SECURITY::ARREST::STATE::NONE, list(SECURITY::ARREST::STATE::ARREST, SECURITY::ARREST::STATE::DETAIN, SECURITY::ARREST::STATE::NONE, SECURITY::ARREST::STATE::SUSPECT, SECURITY::ARREST::STATE::INCARCERATED, SECURITY::ARREST::STATE::PAROLE, SECURITY::ARREST::STATE::RELEASED)),
		"sec_flag"	= new /datum/record_field/string("SecHUD Flag", "None", @".{0,10}"),
		"mi_crim"	= new /datum/record_field/string("Minor Crimes", "None"),
		"mi_crim_d"	= new /datum/record_field/string("Details", "No minor crime convictions."),
		"ma_crim"	= new /datum/record_field/string("Major Crimes", "None"),
		"ma_crim_d"	= new /datum/record_field/string("Details", "No major crime convictions."),
		"notes"		= new /datum/record_field/string("Important Notes", "No notes."),
	)

/datum/db_record/personnel/security/init_from_human(mob/living/carbon/human/H)
	src["id"] = H.datacore_id
	src["name"] = H.real_name

	if (H.traitHolder?.hasTrait("training_clown"))
		src["criminal"] = SECURITY::ARREST::STATE::CLOWN
		src["mi_crim"] = "Clown"
		H.update_arrest_icon()

	if (H.client?.preferences?.security_note)
		src["notes"] = H.client?.preferences?.security_note
