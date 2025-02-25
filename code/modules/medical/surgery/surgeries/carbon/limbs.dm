/datum/surgery/limb_surgery
	name = "Limb Surgery"
	desc = "Modify the patients' limbs."
	visible = FALSE

	default_sub_surgeries = list(/datum/surgery/limb/l_arm,/datum/surgery/limb/attach/arm/left,
	/datum/surgery/limb/r_arm,/datum/surgery/limb/attach/arm/right,
	/datum/surgery/limb/l_leg,/datum/surgery/limb/attach/leg/left,
	/datum/surgery/limb/r_leg,/datum/surgery/limb/attach/leg/right
	)

/datum/surgery/limb
	name = "Base Limb Surgery"
	desc = "Call a coder if you see this!"
	icon_state = "heart"
	var/limb_var_name = "limb_var_name"
	restart_when_finished = TRUE
	exit_when_finished = TRUE
	implicit = TRUE
	visible = FALSE

	surgery_possible(mob/living/surgeon)
		if (!iscarbon(patient))
			return FALSE
		var/mob/living/carbon/human/C = patient
		if (surgeon.zone_sel.selecting != limb_var_name)
			return FALSE
		if (C.limbs?.get_limb(limb_var_name))
			return TRUE
		return FALSE
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new/datum/surgery_step/limb/cut(src, limb_var_name)) // Makes the organ count as 'in surgery'
		add_next_step(new/datum/surgery_step/limb/saw(src, limb_var_name)) // Makes the organ unsecure
		add_next_step(new/datum/surgery_step/limb/remove(src, limb_var_name)) // Removes the organ

	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		surgery_steps[1].finished = (limb?.remove_stage >= 1)
		surgery_steps[2].finished = (limb?.remove_stage >= 2)

	l_arm
		name = "Left Arm Surgery"
		desc = "Remove the patients' left arm."
		icon_state = "left_arm"
		limb_var_name = "l_arm"
		affected_zone = "l_arm"
	r_arm
		name = "Right Arm Surgery"
		desc = "Remove the patients' right arm."
		icon_state = "right_arm"
		limb_var_name = "r_arm"
		affected_zone = "r_arm"
	l_leg
		name = "Left Leg Surgery"
		desc = "Remove the patients' left leg."
		icon_state = "left_leg"
		limb_var_name = "l_leg"
		affected_zone = "l_leg"
	r_leg
		name = "Right Leg Surgery"
		desc = "Remove the patients' right leg."
		icon_state = "right_leg"
		limb_var_name = "r_leg"
		affected_zone = "r_leg"

/datum/surgery/limb/attach
	name = "Limb Addition"
	desc = "Replace the patients' limbs."
	implicit = TRUE
	visible = FALSE
	restart_when_finished = TRUE
	exit_when_finished = TRUE
	//tool needed
	surgery_possible(mob/living/surgeon)
		if (!iscarbon(patient))
			return FALSE
		var/mob/living/carbon/human/C = patient
		if (surgeon.zone_sel.selecting != limb_var_name)
			return FALSE
		return TRUE
	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		surgery_steps[1].finished = (limb != null)
		surgery_steps[2].finished = (limb?.remove_stage == 0)
	arm
		can_operate(mob/living/surgeon, mob/user)
			var/mob/living/carbon/human/C = patient
			if (!C?.limbs?.get_limb(limb_var_name) && get_surgery_progress()) //restart if limb falls off again
				restart_surgery()
			return ..()
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step( new/datum/surgery_step/limb/attach_arm(src,limb_var_name))
			add_next_step( new/datum/surgery_step/limb/secure(src,limb_var_name))
		left
			name = "Left Arm Replacement"
			desc = "Replace the patients' left arm."
			icon_state = "left_arm"
			limb_var_name = "l_arm"
			affected_zone = "l_arm"
		right
			name = "Right Arm Replacement"
			desc = "Replace the patients' right arm."
			icon_state = "right_arm"
			limb_var_name = "r_arm"
			affected_zone = "r_arm"
	leg
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step( new/datum/surgery_step/limb/attach_leg(src,limb_var_name))
			add_next_step( new/datum/surgery_step/limb/secure(src,limb_var_name))
		left
			name = "Left Leg Replacement"
			desc = "Replace the patients' left leg."
			icon_state = "left_leg"
			limb_var_name = "l_leg"
			affected_zone = "l_leg"
		right
			name = "Right Leg Replacement"
			desc = "Replace the patients' right leg."
			icon_state = "right_leg"
			limb_var_name = "r_leg"
			affected_zone = "r_leg"
