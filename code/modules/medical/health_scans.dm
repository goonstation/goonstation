/// Get health data for TGUI interfaces
///
/// Arguments:
/// * include_organs (boolean: FALSE) - include organ data
/// * include_reagents (boolean: FALSE) - include reagent data
/// * include_genetics (boolean: FALSE) - include genetic defect / clone generation data
/// * include_diseases (boolean: FALSE) - include disease information
/// * syndicate_scan (boolean: FALSE) - include syndicate implant information
/// * admin_scan (boolean: FALSE) - include all implant information
/mob/living/carbon/human/proc/ui_health_data(include_organs=FALSE, include_reagents=FALSE, include_genetics=FALSE, include_diseases=FALSE, syndicate_scan=FALSE, admin_scan=FALSE)
	. = list()

	.["patient_name"] = src.name

	var/death_state = src.stat
	var/datum/abilityHolder/changeling/changeling_ability_holder = src.get_ability_holder(/datum/abilityHolder/changeling)
	if (src.bioHolder?.HasEffect("dead_scan") || changeling_ability_holder?.in_fakedeath)
		death_state = STAT_DEAD
	.["patient_status"] = death_state

	.["max_health"] = round(src.max_health)
	.["current_health"] = round(src.health)
	.["brute"] = round(src.get_brute_damage())
	.["burn"] = round(src.get_burn_damage())
	.["toxin"] = round(src.get_toxin_damage())
	.["oxygen"] = round(src.get_oxygen_deprivation())

	.["rad_dose"] = src.radiation_dose
	var/datum/statusEffect/simpledot/radiation/rad_status = src.hasStatus("radiation")
	if (rad_status?.stage)
		.["rad_stage"] = rad_status.stage
	else
		.["rad_stage"] = 0

	if (global.blood_system && src.can_bleed && src.blood_pressure)
		if (isvampire(src))
			.["blood_volume"] = 500
			.["bleeding"] = 0
		else
			.["blood_volume"] = src.blood_pressure["total"]
			.["bleeding"] = src.bleeding
		.["blood_pressure_status"] = src.blood_pressure["status"]
		.["blood_pressure_rendered"] = src.blood_pressure["rendered"]
	else
		.["blood_volume"] = null
		.["bleeding"] = null
		.["blood_pressure_status"] = null
		.["blood_pressure_rendered"] = null

	.["blood_type"] = src.bioHolder?.bloodType
	var/datum/color/blood_color_value = new()
	blood_color_value.from_hex(src.blood_color)
	.["blood_color_name"] = get_nearest_color(blood_color_value)
	.["blood_color_value"] = blood_color_value.to_rgb()

	.["limb_status"] = src.ui_limb_data()

	.["age"] = src.bioHolder?.age
	.["body_temp"] = src.bodytemperature
	.["optimal_temp"] = src.base_body_temp
	.["interesting"] = src.interesting

	if (include_organs && src.organHolder)
		.["organ_status"] = src.ui_organ_data()
		.["embedded_objects"] = src.ui_embedded_objects(syndicate_scan, admin_scan)
		if (src.organHolder.brain)
			.["brain_damage"] = src.organHolder.brain.get_damage()
		else
			.["brain_damage"] = "Missing"
	else
		.["organ_status"] = null
		.["brain_damage"] = null
		.["embedded_objects"] = null

	if (include_genetics)
		.["clone_generation"] = src.bioHolder?.clone_generation
		.["genetic_stability"] = src.bioHolder?.genetic_stability
		if (src.cloner_defects)
			var/datum/cloner_defect_holder/cloner_defects = src.cloner_defects
			.["cloner_defect_count"] = length(cloner_defects.active_cloner_defects)
		else
			.["cloner_defect_count"] = 0
	else
		.["clone_generation"] = null
		.["genetic_stability"] = null
		.["cloner_defect_count"] = null

	if (include_reagents)
		.["reagent_container"] = global.ui_describe_reagents(src)
	else
		.["reagent_container"] = null

	if (include_diseases)
		.["disease_status"] = src.ui_disease_data()
	else
		.["disease_status"] = null

/// Get information about limbs for TGUI ui_data
/mob/living/carbon/human/proc/ui_limb_data()
	. = list()

	. += list(ui_per_limb_data("Left Arm", src.limbs?.l_arm))
	. += list(ui_per_limb_data("Right Arm", src.limbs?.r_arm))
	. += list(ui_per_limb_data("Left Leg", src.limbs?.l_leg))
	. += list(ui_per_limb_data("Right Leg", src.limbs?.r_leg))

	var/butt_status = "Okay"
	if(!src.organHolder || !src.organHolder.butt)
		butt_status = "Missing"
	else
		if (istype(src.organHolder.butt, /obj/item/clothing/head/butt/cyberbutt))
			butt_status = "Cybernetic"
	. += list(list(
		"limb_name" = "Butt",
		"status" = butt_status,
	))

/// Get the per-limb data for TGUI ui_data
/mob/living/carbon/human/proc/ui_per_limb_data(limb_name, obj/item/parts/given_limb)
	// this doesn't need to be a proc on human but i don't wanna pollute the global namespace. anonymous functions pls :(
	var/limb_status = "Okay"
	if (!given_limb)
		limb_status = "Missing"
	else if (isitemlimb(given_limb))
		limb_status = given_limb.remove_object
	else if (isrobolimb(given_limb))
		limb_status = "Cybernetic"
	else if (isartifactlimb(given_limb))
		limb_status = "UNKNOWN"
	. = list(
		"limb_name" = limb_name,
		"status" = limb_status
	)

/// Get embedded objects/implants for TGUI
/mob/living/carbon/human/proc/ui_embedded_objects(syndicate_scan=FALSE, admin_scan=FALSE)
	var/foreign_object_count = 0
	var/has_chest_object = FALSE
	var/implant_count = 0
	var/list/implant_data = list()
	if (length(src.implant))
		var/list/implant_list = list()
		for (var/obj/item/implant/I in src.implant)
			if (istype(I, /obj/item/implant/projectile))
				foreign_object_count++
				continue
			if (I.scan_category == IMPLANT_SCAN_CATEGORY_NOT_SHOWN)
				if (admin_scan)
					implant_count++
					implant_list[capitalize(I.name)]++
				continue
			if (I.scan_category != IMPLANT_SCAN_CATEGORY_SYNDICATE)
				implant_count++
				if (I.scan_category != IMPLANT_SCAN_CATEGORY_UNKNOWN)
					implant_list[capitalize(I.name)]++
				else
					if (admin_scan)
						implant_list[capitalize(I.name)]++
					else
						implant_list["Unknown implant"]++
			else if (syndicate_scan || admin_scan)
				implant_count++
				implant_list[capitalize(I.name)]++

		if (length(implant_list))
			for (var/implant in implant_list)
				implant_data += list(list(
					"implant_name" = implant,
					"implant_count" = implant_list[implant],
				))

	if(src.chest_item != null)
		foreign_object_count++
		has_chest_object = TRUE

	return list(
		"implants" = implant_data,
		"total_implant_count" = implant_count,
		"foreign_object_count" = foreign_object_count,
		"has_chest_object" = has_chest_object,
	)

// Return info on all organs for use in TGUI
/mob/living/carbon/human/proc/ui_organ_data()
	. = list()

	if (isvampire(src)) //Don't give organ readings for Vamps.
		return
	if (!src.organHolder)
		return

	var/list/organs_to_check = list("heart", "left_eye", "right_eye", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")
	if(src.organHolder.tail || src.mob_flags & SHOULD_HAVE_A_TAIL)
		organs_to_check += "tail"

	for (var/organ_name in organs_to_check)
		var/obj/item/organ/organ = src.get_organ(organ_name)
		var/special = ""
		if (!organ)
			special = "Missing"
		else
			if (organ.robotic)
				special = "Cybernetic"
			if (organ.synthetic)
				special = "Synthetic"
			if (organ.unusual)
				special = "Unusual"
		. += list(list(
			"organ_name" = organ_name,
			"special" = special,
			"damage" = organ ? organ.get_damage() : 0,
			"max_health"= organ ? organ.max_damage : 0,
		))

/// Return info on all diseases for TGUI
/mob/living/carbon/human/proc/ui_disease_data()
	. = list()
	for (var/datum/ailment_data/A in src.ailments)
		. += list(A.ui_disease_data())
