/datum/targetable/changeling/morph_arm
	name = "Morph Arm"
	desc = "Shapeshift one of your arms temporarily."
	icon_state = "morph_arm"
	cooldown = 1800
	targeted = 0
	target_anything = 0
	pointCost = 0
	can_use_in_container = 1
	var/list/potential_r_arms = list(/obj/item/parts/human_parts/arm/right/claw, /obj/item/parts/human_parts/arm/right/abomination)
	var/list/potential_l_arms = list(/obj/item/parts/human_parts/arm/left/claw,/obj/item/parts/human_parts/arm/left/abomination)

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/human/H = holder.owner

		if (!ishuman(H) || !(H.limbs.l_arm || H.limbs.r_arm))
			boutput(holder.owner, "<span class='notice'>We have no arms to transform!</span>")
			return 1

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
		choices += ("Claw (DNA cost : 4)")
		choices += ("Abomination (DNA cost : 6)")

		var/choice = tgui_input_list(holder.owner, "Select a form for our arm:", "Select Arm", choices)
		if (!choice)
			boutput(holder.owner, "<span class='notice'>We change our mind.</span>")
			return 1
		var/choice_index = choices.Find(choice)
		var/cost = (choice_index == 1) ? 4 : 6

		if (holder.points >= cost)
			holder.points -= cost
		else
			boutput(holder.owner, "<span class='notice'>We do not have enough DNA!</span>")
			return 1

		var/new_limb = 0
		if (target_limb == "r_arm")
			new_limb = potential_r_arms[choice_index]
		else
			new_limb = potential_l_arms[choice_index]
		if (!new_limb)
			return 1

		C.limbs.replace_with(target_limb, new_limb, C, 0)
		var/adjective = pick("terrifying","scary","menacing","badass","deadly","disgusting","grody")
		holder.owner.visible_message(text("<span class='alert'><B>[holder.owner]'s [(target_limb == "r_arm") ? "right" : "left"] arm quivers and rearranges itself into a [adjective] new form!</B></span>"))
		logTheThing(LOG_COMBAT, C, "morphs a [new_limb], [log_loc(C)].")
		playsound(C, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1, 0.2, 1)

		SPAWN(cooldown)
			if (target_limb == "r_arm")
				if (C.limbs.r_arm && istype(C.limbs.r_arm, new_limb))
					C.limbs.replace_with(target_limb, /obj/item/parts/human_parts/arm/right, C, 0)
					boutput(holder.owner, "<span class='notice'><B>Our right arm shrinks back to normal size.</B></span>")
			else
				if (C.limbs.l_arm && istype(C.limbs.l_arm, new_limb))
					C.limbs.replace_with(target_limb, /obj/item/parts/human_parts/arm/left, C, 0)
					boutput(holder.owner, "<span class='notice'><B>Our left arm shrinks back to normal size.</B></span>")
		return 0
