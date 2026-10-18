/datum/surgery/carbon/category/limb
	id = "limb_surgery"
	name = "Limb Surgery"
	desc = "Modify the patients' limbs."
	visible = FALSE
	implicit = TRUE
	affected_zone = ""
	default_sub_surgeries = list(
	/datum/surgery/carbon/limb/arm/left,
	/datum/surgery/carbon/limb/arm/right,
	/datum/surgery/carbon/limb/leg/left,
	/datum/surgery/carbon/limb/leg/right,
	/datum/surgery/carbon/limb_replace/arm/left,
	/datum/surgery/carbon/limb_replace/arm/right,
	/datum/surgery/carbon/limb_replace/leg/left,
	/datum/surgery/carbon/limb_replace/leg/right
	)

/datum/surgery/carbon/limb
	name = "Base Limb Surgery"
	desc = "Call a coder if you see this!"
	id = "limb_surgery_base"
	icon_state = "heart"
	var/limb_var_name = "limb_var_name"
	exit_when_completed = TRUE
	implicit = TRUE
	visible = FALSE
	surgery_possible(mob/living/surgeon)
		if (!iscarbon(patient))
			return FALSE
		if (surgeon.zone_sel.selecting != limb_var_name)
			return FALSE
		return TRUE
	generate_surgery_steps(mob/living/surgeon, mob/user)
		src.add_next_step(new/datum/surgery_step/limb/cut(src, limb_var_name)) // Makes the organ count as 'in surgery'
		src.add_next_step(new/datum/surgery_step/limb/saw(src, limb_var_name)) // Makes the organ unsecure
		src.add_next_step(new/datum/surgery_step/limb/remove(src, limb_var_name)) // Removes the organ

	check_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		surgery_steps[1].completed = (!limb || limb?.remove_stage >= 1)
		surgery_steps[2].completed = (!limb || limb?.remove_stage >= 2)
		surgery_steps[3].completed = (!limb)
		..()

	cancel_possible()
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		return (limb && limb.remove_stage != 0)

	on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		if (limb && limb.remove_stage != 0)
			limb.remove_stage = LIMB_REMOVE_STAGE_SECURE
			if (!quiet && surgeon)
				surgeon.visible_message(SPAN_ALERT("[surgeon] attaches [C.name]'s [limb.name] securely with [tool]."), SPAN_ALERT("You attach [C.name]'s [limb.name] securely with [tool]."))
				logTheThing(LOG_COMBAT, surgeon, "staples [constructTarget(holder,"combat")]'s [patient.name] back on.")
				logTheThing(LOG_DIARY, surgeon, "staples [constructTarget(holder,"diary")]'s [patient.name] back on.", "combat")
	arm
		left
			id = "l_arm_surgery"
			name = "Left Arm Surgery"
			desc = "Remove the patients' left arm."
			icon_state = "left_arm"
			limb_var_name = "l_arm"
			affected_zone = "l_arm"
		right
			id = "r_arm_surgery"
			name = "Right Arm Surgery"
			desc = "Remove the patients' right arm."
			icon_state = "right_arm"
			limb_var_name = "r_arm"
			affected_zone = "r_arm"
	leg
		left
			id = "l_leg_surgery"
			name = "Left Leg Surgery"
			desc = "Remove the patients' left leg."
			icon_state = "left_leg"
			limb_var_name = "l_leg"
			affected_zone = "l_leg"
		right
			id = "r_leg_surgery"
			name = "Right Leg Surgery"
			desc = "Remove the patients' right leg."
			icon_state = "right_leg"
			limb_var_name = "r_leg"
			affected_zone = "r_leg"


/datum/surgery/carbon/limb_replace
	name = "Base Limb Replacement"
	desc = "Call a coder if you see this!"
	id = "limb_replacement_base"
	icon_state = "heart"
	var/limb_var_name = "limb_var_name"
	exit_when_completed = TRUE
	implicit = TRUE
	visible = FALSE

	surgery_conditions_met(mob/surgeon, obj/item/tool)
		// Is this a limb that can easily be attached?
		if (istype(tool, /obj/item/parts/human_parts))
			var/obj/item/parts/human_parts/limb = tool
			if (limb && limb.easy_attach)
				return TRUE
		. = ..()

	surgery_possible(mob/living/surgeon)
		if (!iscarbon(patient))
			return FALSE
		if (surgeon.zone_sel.selecting != affected_zone)
			return FALSE
		return TRUE

	check_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		surgery_steps[1].completed = (limb)
		..()

	cancel_possible()
		return FALSE

	on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		if (limb && limb.remove_stage != 0)
			limb.remove_stage = LIMB_REMOVE_STAGE_SECURE
			if (!quiet && surgeon)
				surgeon.visible_message(SPAN_ALERT("[surgeon] attaches [C.name]'s [limb.name] securely with [tool]."), SPAN_ALERT("You attach [C.name]'s [limb.name] securely with [tool]."))
				logTheThing(LOG_COMBAT, surgeon, "staples [constructTarget(holder,"combat")]'s [patient.name] back on.")
				logTheThing(LOG_DIARY, surgeon, "staples [constructTarget(holder,"diary")]'s [patient.name] back on.", "combat")



	arm
		generate_surgery_steps(mob/living/surgeon, mob/user)
			src.add_next_step( new/datum/surgery_step/limb/attach_arm(src,limb_var_name))
		left
			id = "l_arm_replacement"
			name = "Left Arm Replacement"
			desc = "Replace the patients' left arm."
			icon_state = "left_arm"
			limb_var_name = "l_arm"
			affected_zone = "l_arm"
		right
			id = "r_arm_replacement"
			name = "Right Arm Replacement"
			desc = "Replace the patients' right arm."
			icon_state = "right_arm"
			limb_var_name = "r_arm"
			affected_zone = "r_arm"
	leg
		generate_surgery_steps(mob/living/surgeon, mob/user)
			src.add_next_step( new/datum/surgery_step/limb/attach_leg(src,limb_var_name))
		left
			id = "l_leg_replacement"
			name = "Left Leg Replacement"
			desc = "Replace the patients' left leg."
			icon_state = "left_leg"
			limb_var_name = "l_leg"
			affected_zone = "l_leg"
		right
			id = "r_leg_replacement"
			name = "Right Leg Replacement"
			desc = "Replace the patients' right leg."
			icon_state = "right_leg"
			limb_var_name = "r_leg"
			affected_zone = "r_leg"
