/datum/surgery/limb_surgery
	id = "limb_surgery"
	name = "Limb Surgery"
	desc = "Modify the patients' limbs."
	visible = FALSE
	implicit = TRUE

	default_sub_surgeries = list(/datum/surgery/limb/arm/l_arm,
	/datum/surgery/limb/arm/r_arm,
	/datum/surgery/limb/leg/l_leg,
	/datum/surgery/limb/leg/r_leg,
	)

/datum/surgery/limb
	name = "Base Limb Surgery"
	desc = "Call a coder if you see this!"
	id = "limb_surgery"
	icon_state = "heart"
	var/limb_var_name = "limb_var_name"
	exit_when_finished = TRUE
	implicit = TRUE
	visible = FALSE

	surgery_conditions_met(mob/surgeon, obj/item/tool)
		// Is this a limb that can easily be attached?
		if (istype(tool, /obj/item/parts/human_parts))
			var/obj/item/parts/human_parts/limb = tool
			if (limb.easy_attach)
				return TRUE
		. = ..()


	surgery_possible(mob/living/surgeon)
		if (!iscarbon(patient))
			return FALSE
		if (surgeon.zone_sel.selecting != limb_var_name)
			return FALSE
		return TRUE
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new/datum/surgery_step/limb/cut(src, limb_var_name)) // Makes the organ count as 'in surgery'
		add_next_step(new/datum/surgery_step/limb/saw(src, limb_var_name)) // Makes the organ unsecure
		add_next_step(new/datum/surgery_step/limb/remove(src, limb_var_name)) // Removes the organ

	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		surgery_steps[1].finished = (!limb || limb?.remove_stage >= 1)
		surgery_steps[2].finished = (!limb || limb?.remove_stage >= 2)
		surgery_steps[3].finished = (!limb)

	cancel_possible()
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		return (limb && limb.remove_stage != 0)

	on_cancel(mob/surgeon, obj/item/tool, quiet)
		var/mob/living/carbon/human/C = patient
		var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
		if (limb && limb.remove_stage != 0)
			limb.remove_stage = 0
			surgeon.visible_message(SPAN_ALERT("[surgeon] attaches [C.name]'s [limb.name] securely with [tool]."), SPAN_ALERT("You attach [C.name]'s [limb.name] securely with [tool]."))
			logTheThing(LOG_COMBAT, surgeon, "staples [constructTarget(holder,"combat")]'s [src.name] back on.")
			logTheThing(LOG_DIARY, surgeon, "staples [constructTarget(holder,"diary")]'s [src.name] back on.", "combat")



	arm
		generate_surgery_steps(mob/living/surgeon, mob/user)
			..()
			add_next_step( new/datum/surgery_step/limb/attach_arm(src,limb_var_name))
		infer_surgery_stage()
			var/mob/living/carbon/human/C = patient
			var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
			surgery_steps[4].finished = (limb != null)
		l_arm
			id = "l_arm_surgery"
			name = "Left Arm Surgery"
			desc = "Remove the patients' left arm."
			icon_state = "left_arm"
			limb_var_name = "l_arm"
			affected_zone = "l_arm"
		r_arm
			id = "r_arm_surgery"
			name = "Right Arm Surgery"
			desc = "Remove the patients' right arm."
			icon_state = "right_arm"
			limb_var_name = "r_arm"
			affected_zone = "r_arm"
	leg
		generate_surgery_steps(mob/living/surgeon, mob/user)
			..()
			add_next_step( new/datum/surgery_step/limb/attach_leg(src,limb_var_name))
		infer_surgery_stage()
			var/mob/living/carbon/human/C = patient
			var/obj/item/parts/limb = C.limbs.vars[limb_var_name]
			surgery_steps[4].finished = (limb != null)
		l_leg
			id = "l_leg_surgery"
			name = "Left Leg Surgery"
			desc = "Remove the patients' left leg."
			icon_state = "left_leg"
			limb_var_name = "l_leg"
			affected_zone = "l_leg"
		r_leg
			id = "r_leg_surgery"
			name = "Right Leg Surgery"
			desc = "Remove the patients' right leg."
			icon_state = "right_leg"
			limb_var_name = "r_leg"
			affected_zone = "r_leg"
