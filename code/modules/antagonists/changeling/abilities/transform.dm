/datum/targetable/changeling/monkey
	name = "Lesser Form"
	desc = "Become something much less powerful."
	icon_state = "lesser"
	cooldown = 50
	targeted = 0
	target_anything = 0
	can_use_in_container = 1
	var/last_used_name = null

	onAttach(var/datum/abilityHolder/H)
		..()
		if (H && H.owner) //Wire note: Fix for Cannot read null.real_name
			last_used_name = H.owner.real_name

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/human/H = holder.owner
		if(!istype(H))
			return 1
		if (H.mutantrace)
			if (ismonkey(H))
				if (alert("Are we sure?","Exit this lesser form?","Yes","No") != "Yes")
					return 1
				doCooldown()

				H.transforming = 1
				H.canmove = 0
				H.icon = null
				H.invisibility = 101
				var/atom/movable/overlay/animation = new /atom/movable/overlay( usr.loc )
				animation.icon_state = "blank"
				animation.icon = 'icons/mob/mob.dmi'
				animation.master = src
				flick("monkey2h", animation)
				sleep(4.8 SECONDS)
				qdel(animation)
				qdel(H.mutantrace)
				H.set_mutantrace(null)
				H.transforming = 0
				H.canmove = 1
				H.icon = initial(H.icon)
				H.invisibility = initial(H.invisibility)
				H.update_face()
				H.update_body()
				H.update_clothing()
				H.real_name = last_used_name
				logTheThing("combat", H, null, "leaves lesser form as a changeling, [log_loc(H)].")
				return 0
			else if (isabomination(H))
				boutput(H, "We cannot transform in this form.")
				return 1
			else
				boutput(H, "We cannot transform in this form.")
				return 1
		else
			if (alert("Are we sure?","Assume lesser form?","Yes","No") != "Yes")
				return 1
			last_used_name = H.real_name
			H.monkeyize()
			logTheThing("combat", H, null, "enters lesser form as a changeling, [log_loc(H)].")
			return 0

/datum/targetable/changeling/transform
	name = "Transform"
	desc = "Become someone else!"
	icon_state = "transform"
	cooldown = 0
	targeted = 0
	target_anything = 0
	human_only = 1
	can_use_in_container = 1
	dont_lock_holder = 1

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, __red("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		if (H.absorbed_dna.len < 2)
			boutput(holder.owner, __red("We need to absorb more DNA to use this ability."))
			return 1

		var/target_name = input("Select the target DNA: ", "Target DNA", null) as null|anything in H.absorbed_dna
		if (!target_name)
			boutput(holder.owner, __blue("We change our mind."))
			return 1

		var/datum/bioHolder/D = H.absorbed_dna[target_name]
		var/datum/organHolder/E = H.absorbed_organholder[target_name]

		holder.owner.visible_message(text("<span class='alert'><B>[holder.owner] transforms!</B></span>"))
		logTheThing("combat", holder.owner, target_name, "transforms into [target_name] as a changeling [log_loc(holder.owner)].")
		var/mob/living/carbon/human/C = holder.owner

		// now we need to swap out our limbs with whatever they had
		// cus limb appearance is stored in the limb and whatnot
		// let's see what limbs we have
		var/datum/mutantrace/what_they_were = D.mobAppearance.mutant_race
		var/datum/mutantrace/what_you_are = C.mutantrace
		var/we_have_these_limbs = 0
		var/list/what_they_should_have = list()

		if (C.limbs.l_arm)
			we_have_these_limbs |= LIMB_LEFT_ARM
		if (C.limbs.r_arm)
			we_have_these_limbs |= LIMB_RIGHT_ARM
		if (C.limbs.l_leg)
			we_have_these_limbs |= LIMB_LEFT_LEG
		if (C.limbs.r_leg)
			we_have_these_limbs |= LIMB_RIGHT_LEG

		// let's see if they were missing anything, and if so, generate the kind of limb they should've had
		// 0 = l_arm, 1 = r_arm, 2 = l_leg, 3 = r_leg
		if (what_you_are == what_they_were)	// transforming within mutant race, maybe we can just recolor what we have
			if (!what_you_are || what_you_are == /datum/mutantrace/lizard) // aka, human or lizard
				var/obj/item/parts/human_parts/thislimb
				if(C.limbs.l_arm)
					thislimb = C.limbs.l_arm
					thislimb.colorize_limb_icon(D)
				if(C.limbs.r_arm)
					thislimb = C.limbs.r_arm
					thislimb.colorize_limb_icon(D)
				if(C.limbs.l_leg)
					thislimb = C.limbs.l_leg
					thislimb.colorize_limb_icon(D)
				if(C.limbs.r_leg)
					thislimb = C.limbs.r_leg
					thislimb.colorize_limb_icon(D)
		else // okay then lets build a list of what limbs you should have
			if(what_they_were?.l_limb_arm_type_mutantrace)
				what_they_should_have += what_they_were.l_limb_arm_type_mutantrace
			else
				what_they_should_have += /obj/item/parts/human_parts/arm/left

			if(what_they_were?.r_limb_arm_type_mutantrace)
				what_they_should_have += what_they_were.r_limb_arm_type_mutantrace
			else
				what_they_should_have += /obj/item/parts/human_parts/arm/right

			if(what_they_were?.l_limb_leg_type_mutantrace)
				what_they_should_have += what_they_were.l_limb_leg_type_mutantrace
			else
				what_they_should_have += /obj/item/parts/human_parts/leg/left

			if(what_they_were?.r_limb_leg_type_mutantrace)
				what_they_should_have += what_they_were.r_limb_leg_type_mutantrace
			else
				what_they_should_have += /obj/item/parts/human_parts/leg/right

		// now lets order our bodyparts
		C.limbs.create(C.bioHolder.mobAppearance, C, we_have_these_limbs, what_they_should_have)

		// if they had a tail, you get one too
		var/obj/item/organ/tail/tail2get
		if(E.tail)	// dump the old tail, if they have one
			qdel(C.organHolder.tail)
			tail2get = E.tail.type
			C.organHolder.tail = new tail2get(C, C.organHolder)
		C.real_name = target_name
		C.bioHolder.CopyOther(D)
		//C.limbs.CopyOther(F)
		//C.organHolder.CopyOther(E)
		C.bioHolder.RemoveEffect("husk")
		if (E.head) // please be a head
			C.organHolder.head.head_image = E.head.head_image
			C.organHolder.head.head_image_eyes = E.head.head_image_eyes
			C.organHolder.head.head_image_cust_one = E.head.head_image_cust_one
			C.organHolder.head.head_image_cust_two = E.head.head_image_cust_two
			C.organHolder.head.head_image_cust_three = E.head.head_image_cust_three
			C.organHolder.head.skintone = E.head.skintone
		else // what did you DO to them?? whatever, just make whatever their head would've looked like
			C.organHolder.head.update_icon() // vOv try to call this after the ling got their new bioholder
		C.update_face()
		C.update_body()
		C.update_clothing()
		return 0
