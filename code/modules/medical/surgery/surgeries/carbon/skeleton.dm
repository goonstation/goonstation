
/datum/surgery/skeleton
	id = "skeleton_surgery"
	name = "Skeleton Surgery"
	desc = "Modify an ossified patients' limbs."
	visible = FALSE
	implicit = TRUE

	default_sub_surgeries = list(
	/datum/surgery/limb/skeleton/arm/l_arm,
	/datum/surgery/limb/skeleton/arm/r_arm,
	/datum/surgery/limb/skeleton/leg/l_leg,
	/datum/surgery/limb/skeleton/leg/r_leg,
	/datum/surgery/organ/skeleton_tail,
	/datum/surgery/organ/skeleton_head
	)

	surgery_possible(mob/living/surgeon)
		return isskeleton(patient)


/datum/surgery/limb/skeleton
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new/datum/surgery_step/limb/skeleton/wrench(src, limb_var_name))
		add_next_step(new/datum/surgery_step/limb/skeleton/crowbar(src, limb_var_name))
		add_next_step(new/datum/surgery_step/limb/skeleton/remove(src, limb_var_name))
	surgery_possible(mob/living/surgeon)
		if (!isskeleton(patient) || !patient.organHolder || surgeon.a_intent == INTENT_HARM)
			return FALSE
		return ..()
	surgery_conditions_met(mob/surgeon, obj/item/tool)
		return (isskeleton(patient) && patient.organHolder)
	leg

		l_leg
			id = "skele_l_leg_surgery (Skeleton)"
			name = "Left Leg Surgery"
			desc = "Remove the patients' left leg."
			icon_state = "left_leg"
			limb_var_name = "l_leg"
			affected_zone = "l_leg"
		r_leg
			id = "skele_r_leg_surgery (Skeleton)"
			name = "Right Leg Surgery"
			desc = "Remove the patients' right leg."
			icon_state = "right_leg"
			limb_var_name = "r_leg"
			affected_zone = "r_leg"
	arm
		l_arm
			id = "skele_l_arm_surgery (Skeleton)"
			name = "Left Arm Surgery"
			desc = "Remove the patients' left arm."
			icon_state = "left_arm"
			limb_var_name = "l_arm"
			affected_zone = "l_arm"
		r_arm
			id = "skele_r_arm_surgery"
			name = "Right Arm Surgery (Skeleton)"
			desc = "Remove the patients' right arm."
			icon_state = "right_arm"
			limb_var_name = "r_arm"
			affected_zone = "r_arm"




/datum/surgery/organ/skeleton_head
	implicit = TRUE
	visible = FALSE
	affected_zone = "head"
	id = "skeleton_head_removal"
	name = "Head Removal (Skeleton)"
	desc = "Remove the patients' head."
	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/no_head = !C.organHolder.get_organ("head")
		surgery_steps[1].finished = no_head || C.organHolder.head.op_stage >= 1
		surgery_steps[2].finished = no_head || C.organHolder.head.op_stage >= 2
		surgery_steps[3].finished = no_head
		return

	generate_surgery_steps()
		add_next_step(new/datum/surgery_step/head/skeleton/wrench(src))
		add_next_step(new/datum/surgery_step/head/skeleton/crowbar(src))
		add_next_step(new/datum/surgery_step/head/skeleton/remove(src))
	surgery_conditions_met(mob/surgeon, obj/item/tool)
		return (isskeleton(patient) && patient.organHolder)

	surgery_possible(mob/living/surgeon)
		if (!isskeleton(patient) || !patient.organHolder)
			return FALSE
		if (surgeon.zone_sel.selecting != "head")
			return FALSE
		if (surgeon.a_intent == INTENT_HARM)
			return FALSE
		return TRUE
/datum/surgery/organ/skeleton_tail
	implicit = TRUE
	visible = FALSE
	affected_zone = "head"
	id = "skeleton_tail_removal"
	name = "Tail Removal (Skeleton)"
	desc = "Remove the patients' tail."
	icon_state = "tail"
	organ_var_name = "tail"
	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/organ = C.organHolder.get_organ(organ_var_name)
		surgery_steps[1].finished = (organ == null)
	generate_surgery_steps()
		add_next_step(new/datum/surgery_step/organ/skeleton_tail/crowbar(src))
	surgery_conditions_met(mob/surgeon, obj/item/tool)
		return (isskeleton(patient) && patient.organHolder)

	surgery_possible(mob/living/surgeon)
		if (!isskeleton(patient) || !patient.organHolder)
			return FALSE
		if (surgeon.zone_sel.selecting != "chest")
			return FALSE
		if (surgeon.a_intent != INTENT_GRAB)
			return FALSE
		return TRUE
