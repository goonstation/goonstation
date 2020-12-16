/datum/targetable/changeling/abomination
	name = "Horror Form"
	desc = "Become something much more powerful."
	icon_state = "horror"
	cooldown = 0
	targeted = 0
	target_anything = 0
	can_use_in_container = 1

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/human/H = holder.owner
		if (isabomination(H))
			if (alert("Are we sure?","Exit Horror Form?","Yes","No") != "Yes")
				return 1
			H.revert_from_horror_form()
		else if (ismonkey(H))
			boutput(H, "We cannot transform in this form.")
			return 1
		else
			if (holder.points < 15)
				boutput(holder.owner, __red("We're not strong enough to maintain the form."))
				return 1
			if (alert("Are we sure?","Enter Horror Form?","Yes","No") != "Yes")
				return 1
			H.set_mutantrace(/datum/mutantrace/abomination)
			setalive(H)
			H.real_name = "Shambling Abomination"
			H.name = "Shambling Abomination"
			H.update_face()
			H.update_body()
			H.update_clothing()
			H.abilityHolder.transferOwnership(H)

			H.delStatus("paralysis")
			H.delStatus("stunned")
			H.delStatus("weakened")
			H.delStatus("disorient")
			H.force_laydown_standup()

			logTheThing("combat", H, null, "enters horror form as a changeling, [log_loc(H)].")
			return 0

/mob/proc/revert_from_horror_form()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		qdel(H.mutantrace)
		H.set_mutantrace(null)
		var/datum/abilityHolder/changeling/C = H.get_ability_holder(/datum/abilityHolder/changeling)
		if(!C || C.points < 15)
			boutput(H, __red("You weren't strong enough to change back safely and blacked out!"))
			H.changeStatus("paralysis", 100)
		else
			boutput(H, __red("You revert back to your original form. It leaves you weak."))
			H.changeStatus("weakened", 5 SECONDS)
		if (C)
			C.points = max(C.points - 15, 0)
			var/D = pick(C.absorbed_dna)
			H.real_name = D
			H.name = D
			H.bioHolder.CopyOther(C.absorbed_dna[D])
		H.update_face()
		H.update_body()
		H.update_clothing()
		C?.transferOwnership(H)
		logTheThing("combat", H, null, "voluntarily leaves horror form as a changeling, [log_loc(H)].")
		return 0

/datum/targetable/changeling/scream
	name = "Horrific Scream"
	desc = "A terrorizing scream that causes everyone nearby to become flustered."
	icon_state = "scream"
	cooldown = 100
	targeted = 0
	target_anything = 0
	pointCost = 0
	abomination_only = 1

	cast(atom/target)
		if (..())
			return 1
		holder.owner.visible_message(__red("<B>[holder.owner] screeches loudly! The very noise fills you with dread!</B>"))
		logTheThing("combat", holder.owner, null, "screeches as a changeling in horror form [log_loc(holder.owner)].")
		playsound(holder.owner.loc, 'sound/voice/creepyshriek.ogg', 80, 1) // cogwerks - using ISN's scary goddamn shriek here

		for (var/mob/living/O in viewers(holder.owner, null))
			if (O == holder.owner)
				continue
			O.apply_sonic_stun(0, 0, 0, 10, 70, rand(0, 2))

		return 0
