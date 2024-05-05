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
		var/datum/abilityHolder/changeling/C = H.get_ability_holder(/datum/abilityHolder/changeling)
		if (isabomination(H))
			if (tgui_alert(H,"Are we sure?","Exit Horror Form?",list("Yes","No")) != "Yes")
				return 1
			H.revert_from_horror_form()
		else if (ismonkey(H))
			boutput(H, "We cannot transform in this form.")
			return 1
		else
			if (holder.points < 15)
				boutput(holder.owner, SPAN_ALERT("We're not strong enough to maintain the form."))
				return 1
			if (tgui_alert(H,"Are we sure?","Enter Horror Form?",list("Yes","No")) != "Yes")
				return 1
			H.set_mutantrace(/datum/mutantrace/abomination)
			setalive(H)
			H.real_name = "Shambling Abomination"
			H.UpdateName()
			H.update_face()
			H.update_body()
			H.update_clothing()
			H.abilityHolder.transferOwnership(H)
			C.in_fakedeath = 0
			REMOVE_ATOM_PROPERTY(H, PROP_MOB_CANTMOVE, "regen_stasis")

			H.remove_stuns()
			H.delStatus("disorient")
			H.delStatus("pinned")
			H.force_laydown_standup()

			H.abilityHolder.updateButtons()

			logTheThing(LOG_COMBAT, H, "enters horror form as a changeling, [log_loc(H)].")
			return 0

/mob/proc/revert_from_horror_form()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.set_mutantrace(null)
		var/datum/abilityHolder/changeling/C = H.get_ability_holder(/datum/abilityHolder/changeling)
		if(!C || C.points < 15)
			boutput(H, SPAN_ALERT("You weren't strong enough to change back safely and blacked out!"))
			H.changeStatus("unconscious", 10 SECONDS)
		else
			boutput(H, SPAN_ALERT("You revert back to your original form. It leaves you weak."))
			H.changeStatus("knockdown", 5 SECONDS)
		if (C)
			C.points = max(C.points - 15, 0)
			var/D = pick(C.absorbed_dna)
			H.real_name = D
			H.UpdateName()
			H.bioHolder.CopyOther(C.absorbed_dna[D])
		H.update_face()
		H.update_body()
		H.update_clothing()
		H.abilityHolder.updateButtons()
		C?.transferOwnership(H)
		logTheThing(LOG_COMBAT, H, "voluntarily leaves horror form as a changeling, [log_loc(H)].")
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
		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] screeches loudly! The very noise fills you with dread!</B>"))
		logTheThing(LOG_COMBAT, holder.owner, "screeches as a changeling in horror form [log_loc(holder.owner)].")
		playsound(holder.owner.loc, 'sound/voice/creepyshriek.ogg', 80, 1) // cogwerks - using ISN's scary goddamn shriek here

		for (var/mob/living/O in viewers(holder.owner, null))
			if (O == holder.owner)
				continue
			O.apply_sonic_stun(0, 0, 0, 10, 70, rand(0, 2))

		return 0
