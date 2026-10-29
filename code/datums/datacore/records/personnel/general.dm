/datum/db_record/personnel/general

/datum/db_record/personnel/general/build_fields()
	return alist(
		"id"		= new /datum/record_field/string(src, "ID", "000000", @"[a-f0-9]{6}"),
		"name"		= new /datum/record_field/string(src, "Name", "New Record"),
		"full_name"	= new /datum/record_field/string(src, "Full Name", "New Record"),
		"rank"		= new /datum/record_field/string(src, "Rank", "Unassigned"),
		"sex"		= new /datum/record_field/choice(src, "Sex", "Other", list("Male", "Female", "Other")),
		"pronouns"	= new /datum/record_field/choice(src, "Pronouns", "Unknown", list("he/him", "she/her", "they/them", "it/its", "Unknown")),
		"age"		= new /datum/record_field/number(src, "Age", 0, 0, INFINITY),
		"fprint_r"	= new /datum/record_field/string(src, "Fingerprint (R)", "Unknown"),
		"fprint_l"	= new /datum/record_field/string(src, "Fingerprint (L)", "Unknown"),
		"dna"		= new /datum/record_field/string(src, "DNA"),
		"photo"		= new /datum/record_field/object/photo(src, "Photo"),
		"p_stat"	= new /datum/record_field/choice(src, "Phys Status", "Active", list("Very Active", "Active", "*Unconscious*", "*Deceased*", "In Cryogenic Storage")),
		"m_stat"	= new /datum/record_field/string(src, "Ment Status", "Stable"),
		"syndint"	= new /datum/record_field/string(src, "Synd Intel"),
	)

/datum/db_record/personnel/general/init_from_human(mob/living/carbon/human/H)
	src["id"] = H.datacore_id
	src["name"] = H.real_name
	src["full_name"] = H.real_name
	if (H.mind.assigned_role)
		src["rank"] = H.mind.assigned_role
	src["sex"] = (H.gender == FEMALE) ? "Female" : "Male"
	src["pronouns"] = H.get_pronouns().name
	src["age"] = H.bioHolder.age
	src["fprint_r"] = H.limbs?.r_arm?.limb_print.id
	src["fprint_l"] = H.limbs?.l_arm?.limb_print.id
	src["dna"] = H.bioHolder.Uid

	var/datum/preferences/preferences = H.client?.preferences
	if (preferences)
		if (length(preferences.name_middle))
			var/list/names = splittext(H.real_name, " ")
			if (length(names) >= 2)
				names.Insert(2, preferences.name_middle)
				src["full_name"] = jointext(names, " ")

		src["syndint"] = preferences.synd_int_note

	SPAWN(2 SECONDS)
		if (!src || !H)
			return

		var/icon/I = H.build_flat_icon(SOUTH)
		H.flat_icon = I
		if (!istype(I))
			return

		var/icon/file_icon = icon('icons/turf/floors.dmi', "white")
		file_icon.Blend(I, ICON_OVERLAY)

		var/datum/computer/file/image/IMG = new()
		IMG.ourImage = image(file_icon)
		IMG.ourIcon = file_icon
		IMG.img_name = "photo of [H.real_name]"
		IMG.img_desc = "You can see [H.real_name] in the photo."
		src["photo"] = IMG

/datum/db_record/personnel/general/update_from_scan(mob/living/carbon/human/H)
	. = ..()

	src["sex"] = (H.gender == FEMALE) ? "Female" : "Male"
	src["pronouns"] = H.get_pronouns().name
	src["age"] = H.bioHolder.age

	if (!H.gloves?.print_mask)
		src["fprint_r"] = H.limbs?.r_arm?.limb_print.id
		src["fprint_l"] = H.limbs?.l_arm?.limb_print.id

	src["dna"] = H.bioHolder.Uid
	src["p_stat"] = "Active"
	src["m_stat"] = "Stable"
