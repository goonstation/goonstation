/datum/db_record/personnel/medical
	fields = list(
		"id"			= null,
		"name"			= null,
		"h_imp"			= "No health implant detected.",
		"blood_type"	= "Unknown",
		"mi_dis"		= "None",
		"mi_dis_d"		= "No minor disabilities have been declared.",
		"ma_dis"		= "None",
		"ma_dis_d"		= "No major disabilities have been diagnosed.",
		"alg"			= "None",
		"alg_d"			= "No allergies have been detected in this patient.",
		"cdi"			= "None",
		"cdi_d"			= "No diseases have been diagnosed at the moment.",
		"cl_def"		= "None",
		"cl_def_d"		= "No cloner defects have been recorded.",
		"dnasample"		= null,
		"notes"			= "No notes.",
	)

/datum/db_record/personnel/medical/init_from_human(mob/living/carbon/human/H)
	src["id"] = H.datacore_id
	src["name"] = H.real_name
	src["blood_type"] = "[H.bioHolder.bloodType]"
	src["dnasample"] = global.create_new_dna_sample_file(H)

	if (H.client?.preferences?.medical_note)
		src["notes"] = H.client?.preferences?.medical_note

	if (H.traitHolder)
		var/list/allergies = list()
		var/list/minor_disabilities = list()
		var/list/minor_disability_desc = list()
		var/list/major_disabilities = list()
		var/list/major_disability_desc = list()

		for (var/id as anything in H.traitHolder.traits)
			var/datum/trait/trait = H.traitHolder.traits[id]

			if (istype(trait, /datum/trait/random_allergy))
				var/datum/trait/random_allergy/allergy = trait
				allergies += global.reagent_id_to_name(allergy.allergen)
				continue

			switch (trait.disability_type)
				if (TRAIT_DISABILITY_MINOR)
					minor_disabilities += trait.disability_name
					minor_disability_desc += trait.disability_desc
				if (TRAIT_DISABILITY_MAJOR)
					major_disabilities += trait.disability_name
					major_disability_desc += trait.disability_desc

		if (length(allergies))
			src["alg"] = jointext(allergies, ", ")
			src["alg_d"] = "Allergy information imported from CentCom database."

		if (length(minor_disabilities))
			src["mi_dis"] = jointext(minor_disabilities, ", ")
			src["mi_dis_d"] = jointext(minor_disability_desc, ". ")

		if (length(major_disabilities))
			src["ma_dis"] = jointext(major_disabilities, ", ")
			src["ma_dis_d"] = jointext(major_disability_desc, ". ")
