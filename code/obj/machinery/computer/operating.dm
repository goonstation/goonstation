/obj/machinery/computer/operating
	name = "Operating Computer"
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/computer.dmi'
	icon_state = "operating"
	desc = "Shows information on a patient laying on an operating table."
	can_reconnect = TRUE
	circuit_type = /obj/item/circuitboard/operating

	var/mob/living/carbon/human/victim = null

	var/obj/machinery/optable/table = null
	id = 0
	var/list/victim_data[][] = list()
	var/const/history_max = 25

/obj/machinery/computer/operating/New()
	..()
	SPAWN(0.5 SECONDS)
		connection_scan()

/obj/machinery/computer/operating/connection_scan()
	src.table = locate(/obj/machinery/optable, orange(2,src))

/obj/machinery/computer/operating/attack_hand(mob/user)
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	if (src.victim)
		SEND_SIGNAL(src.victim.reagents, COMSIG_REAGENTS_ANALYZED, user)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer")
		ui.open()

/obj/machinery/computer/operating/process()
	..()
	if (status & (BROKEN | NOPOWER))
		return
	if(src.table && (src.table.check_victim()))
		src.victim = src.table.victim
	else
		src.victim = null
		src.victim_data = null
	if (src.victim)
		src.victim_data += list(sample_victim())
		if (length(src.victim_data) > src.history_max)
			src.victim_data.Cut(1, 2) //drop the oldest entry
		use_power(500)


/obj/machinery/computer/operating/proc/sample_victim()
	. = list()
	.["brute"] = src.victim?.get_brute_damage()
	.["burn"] = src.victim?.get_burn_damage()
	.["toxin"] = src.victim?.get_toxin_damage()
	.["oxygen"] = src.victim?.get_oxygen_deprivation()

/obj/machinery/computer/operating/ui_data(mob/user)
	. = list()
	.["occupied"] = istype(src.victim)
	if(!src.victim)
		return
	var/datum/color/blood_color_value = new()
	blood_color_value.from_hex(src.victim.blood_color)

	// hack for hemoglyph b/c we don't tint blood color properly
	if(src.victim.bioHolder.GetEffect("roach"))
		blood_color_value.from_hex("#009E81") // commented out blood color in `mutantraces.dm`. yep.

	var/datum/statusEffect/simpledot/radiation/R = src.victim.hasStatus("radiation")
	if (R?.stage)
		.["rad_stage"] = R.stage
		.["rad_dose"] = src.victim.radiation_dose
	else
		.["rad_stage"] = 0
		.["rad_dose"] = 0

	.["patient_name"] = src.victim.real_name

	var/death_state = src.victim.stat
	if (src.victim.bioHolder && src.victim.bioHolder.HasEffect("dead_scan"))
		death_state = 2
	.["patient_status"] = death_state

	.["body_temp"] = src.victim.bodytemperature
	.["optimal_temp"] = src.victim.base_body_temp

	.["patient_data"] = src.victim_data

	.["max_health"] = round(src.victim.max_health)
	.["current_health"] = round(src.victim.health)
	.["brute"] = round(src.victim.get_brute_damage())
	.["burn"] = round(src.victim.get_burn_damage())
	.["toxin"] = round(src.victim.get_toxin_damage())
	.["oxygen"] = round(src.victim.get_oxygen_deprivation())

	.["blood_volume"] = src.victim.blood_pressure["total"]
	.["blood_pressure_status"] = src.victim.blood_pressure["status"]
	.["blood_pressure_rendered"] = src.victim.blood_pressure["rendered"]

	var/list/brain_damage = calc_brain_damage_severity(src.victim)
	.["brain_damage"] = list (
		"value" = src.victim.get_brain_damage(),
		"desc" = brain_damage[1],
		"color" = brain_damage[2],
	)

	.["embedded_objects"] = check_embedded_objects(src.victim)

	.["organ_status"] = generate_organ_data(src.victim)
	.["limb_status"] = generate_limb_data(src.victim)

	.["age"] = src.victim.bioHolder.age
	.["blood_type"] = src.victim.bioHolder.bloodType
	.["blood_color_name"] = get_nearest_color(blood_color_value)
	.["blood_color_value"] = blood_color_value.to_rgb()
	.["clone_generation"] = src.victim.bioHolder.clone_generation
	.["genetic_stability"] = src.victim.bioHolder.genetic_stability

	.["cloner_defect_count"] = 0
	if (src.victim.cloner_defects)
		var/datum/cloner_defect_holder/cloner_defects = src.victim.cloner_defects
		var/list/datum/cloner_defect/active_cloner_defects = cloner_defects.active_cloner_defects
		.["cloner_defect_count"] = length(active_cloner_defects)

	.["reagent_container"] = ui_describe_reagents(src.victim)


/obj/machinery/computer/operating/proc/generate_organ_data(var/mob/living/carbon/human/H)
	var/list/organ_data = list()

	if (isvampire(H))
		return organ_data
	if (!H.organHolder)
		return organ_data

	var/list/organs_to_check = list("heart", "left_eye", "right_eye", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")
	if(H.organHolder.tail || H.mob_flags & SHOULD_HAVE_A_TAIL)
		organs_to_check += "tail"

	for (var/organ_name in organs_to_check)
		var/obj/item/organ/O = H.get_organ(organ_name)
		var/damage = ""
		var/color = "grey"
		var/special = ""
		if (O == 0 || !O)
			damage = "Missing"
			color = "Red"
		else
			if (O.robotic)
				special = "Cybernetic"
			if (O.unusual)
				special = "Unusual"
			var/list/organ_calc = calc_organ_damage_severity(O)
			damage = organ_calc[1]
			color = organ_calc[2]

		organ_data += list(list(
			"organ" = organ_name,
			"state" = damage,
			"color" = color,
			"special" = special,
		))

	return organ_data

/obj/machinery/computer/operating/proc/calc_brain_damage_severity(var/mob/living/carbon/human/H)
	var/brain = H.get_organ("brain")
	if (!brain)
		return list("Missing", "red")
	var/brain_damage = H.get_brain_damage()
	if(brain_damage >= 100)
		return list("Braindead", "red")
	if(brain_damage >= 60)
		return list("Severe", "orange")
	if(brain_damage >= 10)
		return list("Significant", "yellow")
	return list("Okay", "green")

/obj/machinery/computer/operating/proc/calc_organ_damage_severity(var/obj/item/organ/O)
	var/damage = O.get_damage()
	if (damage >= O.max_damage)
		return list("Dead", "red")
	if (damage >= O.max_damage*0.9)
		return list("Critical", "orange")
	if (damage >= O.max_damage*0.65)
		return list("Significant", "orange")
	if (damage >= O.max_damage*0.3)
		return list("Moderate", "yellow")
	if (damage > 0)
		return list("Minor", "green")
	return list("Okay", "green")

/obj/machinery/computer/operating/proc/generate_limb_data(var/mob/living/carbon/human/H)
	var/list/limb_data = list()
	var/current_status = ""
	var/current_limb = ""
	if (H.limbs)
		current_limb = "Left Arm"
		current_status = "Okay"
		if (!H.limbs.l_arm)
			current_status = "Missing"
		else
			if (istype(H.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item))
				var/obj/item/parts/human_parts/arm/left/item/I = H.limbs.l_arm
				current_status = I.remove_object
			else if (istype(H.limbs.l_arm, /obj/item/parts/robot_parts/arm/left/))
				current_status = "Cybernetic"
			else if (istype(H.limbs.l_arm, /obj/item/parts/artifact_parts/arm/))
				current_status = "UNKNOWN"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

		current_limb = "Right Arm"
		current_status = "Okay"
		if (!H.limbs.r_arm)
			current_status = "Missing"
		else
			if (istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item))
				var/obj/item/parts/human_parts/arm/right/item/I = H.limbs.r_arm
				current_status = I.remove_object
			else if (istype(H.limbs.r_arm, /obj/item/parts/robot_parts/arm/right))
				current_status = "Cybernetic"
			else if (istype(H.limbs.r_arm, /obj/item/parts/artifact_parts/arm/))
				current_status = "UNKNOWN"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

		current_limb = "Left Leg"
		current_status = "Okay"
		if (!H.limbs.l_leg)
			current_status = "Missing"
		else
			if (istype(H.limbs.l_leg, /obj/item/parts/robot_parts/leg/left))
				current_status = "Cybernetic"
			else if (istype(H.limbs.l_leg, /obj/item/parts/artifact_parts/leg/))
				current_status = "UNKNOWN"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

		current_limb = "Right Leg"
		current_status = "Okay"
		if (!H.limbs.r_leg)
			current_status = "Missing"
		else
			if (istype(H.limbs.r_leg, /obj/item/parts/robot_parts/leg/right))
				current_status = "Cybernetic"
			else if (istype(H.limbs.r_leg, /obj/item/parts/artifact_parts/leg/))
				current_status = "UNKNOWN"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

		current_limb = "Butt" // look. okay. where else do i put it?
		current_status = "Okay"
		if(!H.organHolder?.butt)
			current_status = "Missing"
		else
			if (istype(H.organHolder.butt, /obj/item/clothing/head/butt/cyberbutt))
				current_status = "Cybernetic"
		limb_data += list(list(
			"limb" = current_limb,
			"status" = current_status,
		))

	return limb_data

/obj/machinery/computer/operating/proc/check_embedded_objects(var/mob/living/L)
	var/foreign_object_count = 0
	var/implant_count = 0
	var/has_chest_object = FALSE
	if (length(L.implant))
		for (var/obj/item/implant/I in L.implant)
			if (istype(I, /obj/item/implant/projectile))
				foreign_object_count++
				continue
			if (I.scan_category == "not_shown")
				continue
			if (I.scan_category != "syndicate")
				implant_count++

	if (ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.chest_item != null)
			foreign_object_count++
			has_chest_object = TRUE

	return list(
		"foreign_object_count" = foreign_object_count,
		"implant_count" = implant_count,
		"has_chest_object" = has_chest_object,
	)
