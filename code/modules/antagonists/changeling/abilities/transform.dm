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

		holder.owner.visible_message(text("<span class='alert'><B>[holder.owner] transforms!</B></span>"))
		logTheThing("combat", holder.owner, target_name, "transforms into [target_name] as a changeling [log_loc(holder.owner)].")
		var/mob/living/carbon/human/C = holder.owner
		var/datum/bioHolder/D = H.absorbed_dna[target_name]
		var/datum/mutantrace/what_they_were = D.mobAppearance.mutant_race
		C.bioHolder.CopyOther(D)

		// now we need to swap out our limbs with whatever they had
		// cus limb appearance is stored in the limb and whatnot

		var/list/limbs_to_check = list(C.limbs.l_arm, C.limbs.r_arm, C.limbs.l_leg, C.limbs.r_leg)
		var/list/human_limbs = list(/obj/item/parts/human_parts/arm/left, /obj/item/parts/human_parts/arm/right, /obj/item/parts/human_parts/leg/left, /obj/item/parts/human_parts/leg/right)
		var/list/limbs_to_add = list()

		if (what_they_were?.limb_list) // setup the limbs we should have based on their DNA
			limbs_to_add = what_they_were.limb_list
		else // they're human or don't have any special limbs, okay neat
			limbs_to_add = human_limbs

		var/limb_list_index = 0
		for(var/obj/item/parts/limb in limbs_to_check)
			limb_list_index ++	// no index skipping, please
			if (limb_list_index > 4)
				break
			if(!limb) // we're missing that limb, and tf isnt gonna help that
				continue
			if (istype(limb, /obj/item/parts/human_parts/)) // will probably overwrite anything that isnt robot arms
				var/obj/item/parts/add_this_limb = limbs_to_add[limb_list_index]
				if(!add_this_limb)
					add_this_limb = human_limbs[limb_list_index]
				limb.delete() // we dont care about mundane limbs. Plus we can just tf into a wolf to get werewolf arms anyway
				switch (limb_list_index)
					if (1)
						C.limbs.l_arm = new add_this_limb(C, D.mobAppearance)
					if (2)
						C.limbs.r_arm = new add_this_limb(C, D.mobAppearance)
					if (3)
						C.limbs.l_leg = new add_this_limb(C, D.mobAppearance)
					if (4)
						C.limbs.r_leg = new add_this_limb(C, D.mobAppearance)
			else // Special limbs, like robot stuff
				continue // let's keep those

		// if they had a tail, you get one too
		if(C.organHolder.tail)
			qdel(C.organHolder.tail)
			C.organHolder.tail = null
			C.organHolder.organ_list["tail"] = null
		if(what_they_were?.tail_type)	// dump the old tail, if they have one
			var/obj/item/organ/tail/newtail = what_they_were.tail_type
			C.organHolder.tail = new newtail(C, C.organHolder)
			C.organHolder.organ_list["tail"] = newtail
		C.real_name = target_name
		C.bioHolder.RemoveEffect("husk")
		C.organHolder.head.update_icon()
		if (C.bioHolder?.mobAppearance?.mutant_race)
			C.set_mutantrace(C.bioHolder.mobAppearance.mutant_race)
		else
			C.set_mutantrace(null)

		C.update_face()
		C.update_body()
		C.update_clothing()
		return 0
