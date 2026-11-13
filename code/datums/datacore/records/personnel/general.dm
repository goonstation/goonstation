/datum/db_record/personnel/general

/datum/db_record/personnel/general/build_fields()
	return alist(
		BUILD_FIELD("id",			/datum/record_field/string,			"ID", "000000", @"[a-f0-9]{6}"),
		BUILD_FIELD("name",			/datum/record_field/string,			"Name", "New Record"),
		BUILD_FIELD("full_name",	/datum/record_field/string,			"Full Name", "New Record"),
		BUILD_FIELD("rank",			/datum/record_field/string,			"Rank", "Unassigned"),
		BUILD_FIELD("sex",			/datum/record_field/choice,			"Sex", "Other", list("Male", "Female", "Other")),
		BUILD_FIELD("pronouns",		/datum/record_field/choice,			"Pronouns", "Unknown", list("he/him", "she/her", "they/them", "it/its", "Unknown")),
		BUILD_FIELD("age",			/datum/record_field/number,			"Age", 0, 0, INFINITY),
		BUILD_FIELD("fprint_r",		/datum/record_field/string,			"Fingerprint (R)", "Unknown"),
		BUILD_FIELD("fprint_l",		/datum/record_field/string,			"Fingerprint (L)", "Unknown"),
		BUILD_FIELD("dna",			/datum/record_field/string,			"DNA"),
		BUILD_FIELD("photo",		/datum/record_field/object/photo,	"Photo"),
		BUILD_FIELD("p_stat",		/datum/record_field/choice,			"Phys Status", "Active", list("Very Active", "Active", "*Unconscious*", "*Deceased*", "In Cryogenic Storage")),
		BUILD_FIELD("m_stat",		/datum/record_field/string,			"Ment Status", "Stable"),
		BUILD_FIELD("syndint",		/datum/record_field/string,			"Synd Intel"),
	)

/datum/db_record/personnel/general/to_display_string()
	return "[src["id"]]: [src["name"]]"

/datum/db_record/personnel/general/to_list_display_string()
	return "[src["id"]]: [src["name"]]"

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
	src["name"] = H.real_name
	src["sex"] = (H.gender == FEMALE) ? "Female" : "Male"
	src["pronouns"] = H.get_pronouns().name
	src["age"] = H.bioHolder.age

	if (!H.gloves?.print_mask)
		src["fprint_r"] = H.limbs?.r_arm?.limb_print.id
		src["fprint_l"] = H.limbs?.l_arm?.limb_print.id

	src["dna"] = H.bioHolder.Uid
	src["p_stat"] = "Active"
	src["m_stat"] = "Stable"
