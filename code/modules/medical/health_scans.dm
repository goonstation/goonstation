// Get information about limbs for TGUI ui_data
/mob/living/carbon/human/proc/get_tgui_limb_data()
	var/list/limb_data = list()
	var/current_status = ""
	var/current_limb = ""
	if (src.limbs)
		current_limb = "Left Arm"
		current_status = "Okay"
		if (!src.limbs.l_arm)
			current_status = "Missing"
		else
			if (istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item))
				var/obj/item/parts/human_parts/arm/left/item/I = src.limbs.l_arm
				current_status = I.remove_object
			else if (istype(src.limbs.l_arm, /obj/item/parts/robot_parts/arm/left/))
				current_status = "Cybernetic"
			else if (istype(src.limbs.l_arm, /obj/item/parts/artifact_parts/arm/))
				current_status = "UNKNOWN"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

		current_limb = "Right Arm"
		current_status = "Okay"
		if (!src.limbs.r_arm)
			current_status = "Missing"
		else
			if (istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item))
				var/obj/item/parts/human_parts/arm/right/item/I = src.limbs.r_arm
				current_status = I.remove_object
			else if (istype(src.limbs.r_arm, /obj/item/parts/robot_parts/arm/right))
				current_status = "Cybernetic"
			else if (istype(src.limbs.r_arm, /obj/item/parts/artifact_parts/arm/))
				current_status = "UNKNOWN"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

		current_limb = "Left Leg"
		current_status = "Okay"
		if (!src.limbs.l_leg)
			current_status = "Missing"
		else
			if (istype(src.limbs.l_leg, /obj/item/parts/robot_parts/leg/left))
				current_status = "Cybernetic"
			else if (istype(src.limbs.l_leg, /obj/item/parts/artifact_parts/leg/))
				current_status = "UNKNOWN"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

		current_limb = "Right Leg"
		current_status = "Okay"
		if (!src.limbs.r_leg)
			current_status = "Missing"
		else
			if (istype(src.limbs.r_leg, /obj/item/parts/robot_parts/leg/right))
				current_status = "Cybernetic"
			else if (istype(src.limbs.r_leg, /obj/item/parts/artifact_parts/leg/))
				current_status = "UNKNOWN"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

		current_limb = "Butt" // look. okay. where else do i put it?
		current_status = "Okay"
		if(!src.organHolder?.butt)
			current_status = "Missing"
		else
			if (istype(src.organHolder.butt, /obj/item/clothing/head/butt/cyberbutt))
				current_status = "Cybernetic"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

	return limb_data

/// Get brain damage information formatted for TGUI windows
/mob/living/carbon/human/proc/get_tgui_brain_damage()
	var/brain = src.get_organ("brain")
	if (!brain)
		return list(0, "Missing", "red")
	var/brain_damage = src.get_brain_damage()
	if(brain_damage >= BRAIN_DAMAGE_LETHAL)
		return list(brain_damage, "Braindead", "red")
	if(brain_damage >= BRAIN_DAMAGE_SEVERE)
		return list(brain_damage, "Severe", "red")
	if(brain_damage >= BRAIN_DAMAGE_MAJOR)
		return list(brain_damage, "Major", "red")
	if(brain_damage >= BRAIN_DAMAGE_MODERATE)
		return list(brain_damage, "Moderate", "orange")
	if(brain_damage >= BRAIN_DAMAGE_MINOR)
		return list(brain_damage, "Minor", "yellow")
	return list(brain_damage, "Okay", "green")

/mob/living/carbon/human/proc/get_tgui_embedded_objects(syndicate_scan=FALSE, admin_scan=FALSE)
	var/foreign_object_count = 0
	var/has_chest_object = FALSE
	var/implant_data
	if (length(src.implant))
		var/list/implant_list = list()
		for (var/obj/item/implant/I in src.implant)
			if (istype(I, /obj/item/implant/projectile))
				foreign_object_count++
				continue
			if (I.scan_category == IMPLANT_SCAN_CATEGORY_NOT_SHOWN)
				continue
			if (I.scan_category != IMPLANT_SCAN_CATEGORY_SYNDICATE)
				if (I.scan_category != IMPLANT_SCAN_CATEGORY_UNKNOWN)
					implant_list[capitalize(I.name)]++
				else
					implant_list["Unknown implant"]++
			else if (syndicate_scan || admin_scan)
				implant_list[capitalize(I.name)]++

		if (length(implant_list))
			implant_data = "<span style='color:#2770BF'><b>Implants detected:</b></span>"
			for (var/implant in implant_list)
				implant_data += "<br><span style='color:#2770BF'>[implant_list[implant]]x [implant]</span>"


	if(src.chest_item != null)
		foreign_object_count++
		has_chest_object = TRUE

	return list(
		"implant_data" = implant_data,
		"foreign_object_count" = foreign_object_count,
		"has_chest_object" = has_chest_object,
	)

/mob/living/carbon/human/proc/get_tgui_disease_data(disease_detection=1)
	var/disease_data
	for (var/datum/ailment_data/A in src.ailments)
		disease_data += "<br>[A.scan_info()]"
	return disease_data
