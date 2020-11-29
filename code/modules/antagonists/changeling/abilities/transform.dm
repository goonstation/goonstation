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
		if (H?.owner) //Wire note: Fix for Cannot read null.real_name
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
		C.bioHolder.CopyOther(D)
		C.real_name = target_name
		C.bioHolder.RemoveEffect("husk")
		C.organHolder.head.update_icon()
		if (C.bioHolder?.mobAppearance?.mutant_race)
			C.set_mutantrace(C.bioHolder.mobAppearance.mutant_race.type)
		else
			C.set_mutantrace(null)

		C.update_face()
		C.update_body()
		C.update_clothing()
		return 0
