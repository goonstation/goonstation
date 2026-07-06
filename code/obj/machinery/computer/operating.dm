/obj/machinery/computer/operating
	name = "operating computer"
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

	attackby(obj/item/W, mob/user)
		. = ..()
		if (iswrenchingtool(W) && src.circuit_type)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/computer/operating/proc/change_shape,\
			list(W, user), W.icon, W.icon_state, "[user] changes the shape of the [src].", null)
		else
			src.Attackhand(user)

	get_help_message(dist, mob/user)
		. = "You can use a <b>screwdriver</b> to unscrew the screen"
		if (src.can_reconnect)
			. += ",\nor a <b>multitool</b> to re-scan for equipment. <br> You may also use a <b>wrench</b> to reconfigure the [src] visually."
		else
			. += "."

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
	. += src.victim.ui_health_data(TRUE, TRUE, TRUE, TRUE)
	.["patient_data"] = src.victim_data

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
			if (O.synthetic)
				special = "Synthetic"
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
	if(brain_damage >= BRAIN_DAMAGE_LETHAL)
		return list("Braindead", "red")
	if(brain_damage >= BRAIN_DAMAGE_SEVERE)
		return list("Severe", "red")
	if(brain_damage >= BRAIN_DAMAGE_MAJOR)
		return list("Major", "red")
	if(brain_damage >= BRAIN_DAMAGE_MODERATE)
		return list("Moderate", "orange")
	if(brain_damage >= BRAIN_DAMAGE_MINOR)
		return list("Minor", "yellow")
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


/obj/machinery/computer/operating/small
	density = 0
	icon_state = "operating-small"

/obj/machinery/computer/operating/proc/change_shape()
	if (src.density)
		src.base_icon_state = "operating-small"
	else
		src.base_icon_state = "operating"
	src.power_change() // redraw nopower/broken/screen glow
	src.density = !src.density
