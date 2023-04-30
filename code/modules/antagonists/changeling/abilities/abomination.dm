/datum/targetable/changeling/abomination
	name = "Horror Form"
	desc = "Become something much more powerful."
	icon_state = "horror"
	incapacitation_restriction = ABILITY_CAN_USE_ALWAYS

	cast(atom/target)
		. = ..()
		var/mob/living/carbon/human/H = holder.owner
		if (isabomination(H))
			if (tgui_alert(H,"Are we sure?","Exit Horror Form?",list("Yes","No")) != "Yes")
				return TRUE
			H.revert_from_horror_form()
		else if (ismonkey(H))
			boutput(H, "We cannot transform in this form.")
			return TRUE
		else
			if (holder.points < 15)
				boutput(holder.owner, "<span class='alert'>We're not strong enough to maintain the form.</span>")
				return TRUE
			if (tgui_alert(H,"Are we sure?","Enter Horror Form?",list("Yes","No")) != "Yes")
				return TRUE
			H.set_mutantrace(/datum/mutantrace/abomination)
			setalive(H)
			H.real_name = "Shambling Abomination"
			H.UpdateName()
			H.update_face()
			H.update_body()
			H.update_clothing()
			H.abilityHolder.transferOwnership(H)

			H.delStatus("paralysis")
			H.delStatus("stunned")
			H.delStatus("weakened")
			H.delStatus("disorient")
			H.delStatus("pinned")
			H.force_laydown_standup()

			H.abilityHolder.updateButtons()

			logTheThing(LOG_COMBAT, H, "enters horror form as a changeling, [log_loc(H)].")

/mob/living/carbon/human/proc/revert_from_horror_form()
	qdel(src.mutantrace)
	src.set_mutantrace(null)
	var/datum/abilityHolder/changeling/C = src.get_ability_holder(/datum/abilityHolder/changeling)
	if(!C || C.points < 15)
		boutput(src, "<span class='alert'>You weren't strong enough to change back safely and blacked out!</span>")
		src.changeStatus("paralysis", 10 SECONDS)
	else
		boutput(src, "<span class='alert'>You revert back to your original form. It leaves you weak.</span>")
		src.changeStatus("weakened", 5 SECONDS)
	if (C)
		C.points = max(C.points - 15, 0)
		var/D = pick(C.absorbed_dna)
		src.real_name = D
		src.UpdateName()
		src.bioHolder.CopyOther(C.absorbed_dna[D])
	src.update_face()
	src.update_body()
	src.update_clothing()
	src.abilityHolder.updateButtons()
	C?.transferOwnership(src)
	logTheThing(LOG_COMBAT, H, "voluntarily leaves horror form as a changeling, [log_loc(H)].")

/datum/targetable/changeling/scream
	name = "Horrific Scream"
	desc = "A terrorizing scream that causes everyone nearby to become flustered."
	icon_state = "scream"
	cooldown = 10 SECONDS
	abomination_only = TRUE

	cast(atom/target)
		. = ..()
		holder.owner.visible_message("<span class='alert'><B>[holder.owner] screeches loudly! The very noise fills you with dread!</B></span>")
		logTheThing(LOG_COMBAT, holder.owner, "screeches as a changeling in horror form [log_loc(holder.owner)].")
		playsound(holder.owner.loc, 'sound/voice/creepyshriek.ogg', 80, 1) // cogwerks - using ISN's scary goddamn shriek here

		for (var/mob/living/O in oviewers(holder.owner, null))
			O.apply_sonic_stun(0, 0, 0, 10, 70, rand(0, 2))
