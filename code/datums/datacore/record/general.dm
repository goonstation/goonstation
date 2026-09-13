/datum/db_record/personnel/general
	fields = list(
		"id"				= null,
		"name"				= "New Record",
		"full_name"			= "New Record",
		"rank"				= "Unassigned",
		"sex"				= "Other",
		"pronouns"			= "Unknown",
		"age"				= "Unknown",
		"fingerprint_right"	= "Unknown",
		"fingerprint_left"	= "Unknown",
		"dna"				= null,
		"file_photo"		= null,
		"p_stat"			= "Active",
		"m_stat"			= "Stable",
		"syndint"			= null,
	)

/datum/db_record/personnel/general/init_from_human(mob/living/carbon/human/H)
	src["id"] = H.datacore_id
	src["name"] = H.real_name
	src["full_name"] = H.real_name
	if (H.mind.assigned_role)
		src["rank"] = H.mind.assigned_role
	src["sex"] = (H.gender == FEMALE) ? "Female" : "Male"
	src["pronouns"] = H.get_pronouns().name
	src["age"] ="[H.bioHolder.age]"
	src["fingerprint_right"] = "[H.limbs?.r_arm?.limb_print.id]"
	src["fingerprint_left"] = "[H.limbs?.l_arm?.limb_print.id]"
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

		var/datum/computer/file/image/IMG = new()
		IMG.ourIcon = I
		IMG.img_name = "photo of [H.real_name]"
		IMG.img_desc = "You can see [H.real_name] in the photo."
		src["file_photo"] = IMG
