/datum/targetable/changeling/morph_arm
	name = "Morph Arm"
	desc = "Shapeshift one of your arms temporarily."
	icon_state = "morph_arm"
	cooldown = 180 SECONDS
	var/list/potential_r_arms = list(/obj/item/parts/human_parts/arm/right/claw, /obj/item/parts/human_parts/arm/right/abomination)
	var/list/potential_l_arms = list(/obj/item/parts/human_parts/arm/left/claw, /obj/item/parts/human_parts/arm/left/abomination)

	cast(atom/target)
		. = ..()
		var/mob/living/carbon/human/H = src.holder.owner

		if (!ishuman(H) || !(H.limbs.l_arm || H.limbs.r_arm))
			boutput(holder.owner, SPAN_NOTICE("We have no arms to transform!"))
			return TRUE

		if (H.limbs.l_arm && H.limbs.r_arm) //if both arms are available, replace the active one
			if (H.hand)
				return replace_arm(H, "l_arm")
			else
				return replace_arm(H, "r_arm")
		else if (H.limbs.l_arm)
			return replace_arm(H, "r_arm")
		else
			return replace_arm(H, "l_arm")

	proc/replace_arm(var/mob/living/carbon/human/C, var/target_limb = "r_arm")
		var/list/choices = list()
		choices += ("Claw (DNA cost : 0)") // this really needs to use context actions or something christ
		choices += ("Abomination (DNA cost : 10)")

		var/choice = tgui_input_list(holder.owner, "Select a form for our arm:", "Select Arm", choices)
		if (!choice)
			boutput(holder.owner, SPAN_NOTICE("We change our mind."))
			return TRUE
		var/choice_index = choices.Find(choice)
		var/cost = (choice_index == 1) ? 0 : 10 // this is so fucking hard coded my god

		if (holder.points >= cost) // AWWW YEAH LET'S JUST BYPASS POINT SPENDING MECHANICS AND DO IT OURSELVES YEEEEEAH
			holder.points -= cost
		else
			boutput(holder.owner, SPAN_NOTICE("We do not have enough DNA!"))
			return TRUE

		var/new_limb
		if (target_limb == "r_arm")
			new_limb = potential_r_arms[choice_index]
		else

		C.limbs.replace_with(target_limb, new_limb, C, 0)
		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner]'s [(target_limb == "r_arm") ? "right" : "left"] arm quivers and rearranges itself into a [adjective] new form!</B>"))
		logTheThing(LOG_COMBAT, C, "morphs a [new_limb], [log_loc(C)].")

		SPAWN(cooldown)
			if (target_limb == "r_arm")
				if (C.limbs.r_arm && istype(C.limbs.r_arm, new_limb))
					C.limbs.replace_with(target_limb, /obj/item/parts/human_parts/arm/right, C, 0)
					boutput(holder.owner, SPAN_NOTICE("<B>Our right arm shrinks back to normal size.</B>"))
			else
				if (C.limbs.l_arm && istype(C.limbs.l_arm, new_limb))
					C.limbs.replace_with(target_limb, /obj/item/parts/human_parts/arm/left, C, 0)
					boutput(holder.owner, SPAN_NOTICE("<B>Our left arm shrinks back to normal size.</B>"))
