/datum/db_record/personnel/medical
	fields = alist(
		"id"			= new /datum/record_field/string("ID", "000000", @"[a-f0-9]{6}"),
		"name"			= new /datum/record_field/string("Name", "New Record"),
		"h_imp"			= new /datum/record_field/string("Current Health", "No health implant detected."),
		"blood_type"	= new /datum/record_field/choice("Blood Type", "Unknown", list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Zesty Ranch", "Unknown")),
		"mi_dis"		= new /datum/record_field/string("Minor Disabilities", "None"),
		"mi_dis_d"		= new /datum/record_field/string("Details", "No minor disabilities have been declared."),
		"ma_dis"		= new /datum/record_field/string("Major Disabilities", "None"),
		"ma_dis_d"		= new /datum/record_field/string("Details", "No major disabilities have been diagnosed."),
		"alg"			= new /datum/record_field/string("Allergies", "None"),
		"alg_d"			= new /datum/record_field/string("Details", "No allergies have been detected in this patient."),
		"cdi"			= new /datum/record_field/string("Current Diseases", "None"),
		"cdi_d"			= new /datum/record_field/string("Details", "No diseases have been diagnosed at the moment."),
		"cl_def"		= new /datum/record_field/string("Cloner Defects", "None"),
		"cl_def_d"		= new /datum/record_field/string("Details", "No cloner defects have been recorded."),
		"dnasample"		= new /datum/record_field/object("DNA Sample", null, /datum/computer/file/genetics_scan),
		"notes"			= new /datum/record_field/string("Important Notes", "No notes."),
	)

/datum/db_record/personnel/medical/init_from_human(mob/living/carbon/human/H)
	src["id"] = H.datacore_id
	src["name"] = H.real_name
	src["blood_type"] = H.bioHolder.bloodType
	src["dnasample"] = global.create_new_dna_sample_file(H)

	if (H.client?.preferences?.medical_note)
		src["notes"] = H.client?.preferences?.medical_note

	src.get_traits(H)

/datum/db_record/personnel/medical/update_from_scan(mob/living/carbon/human/H)
	. = ..()
	src["blood_type"] = H.bioHolder.bloodType
	src.get_traits(H)

/datum/db_record/personnel/medical/proc/get_traits(mob/living/carbon/human/H)
	if (!H.traitHolder)
		return

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
