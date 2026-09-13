/datum/db_record/personnel/security
	fields = list(
		"id"		= null,
		"name"		= null,
		"criminal"	= SECURITY::ARREST::STATE::NONE,
		"sec_flag"	= "None",
		"mi_crim"	= "None",
		"mi_crim_d"	= "No minor crime convictions.",
		"ma_crim"	= "None",
		"ma_crim_d"	= "No major crime convictions.",
		"notes"		= "No notes.",
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
