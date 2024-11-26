/datum/abilityHolder/changeling
	usesPoints = 1
	regenRate = 0
	tabName = "Changeling"
	notEnoughPointsMessage = SPAN_ALERT("We are not strong enough to do this.")
	var/list/absorbed_dna = list()
	var/in_fakedeath = 0
	var/absorbtions = 0
	var/list/hivemind = list()
	//If we relinquish control of the body to a subordinate.
	var/mob/dead/target_observer/hivemind_observer/master = null
	var/mob/dead/target_observer/hivemind_observer/temp_controller = null
	var/original_controller_name = null
	var/original_controller_real_name = null

	New(var/mob/living/M)
		..()
		if (M)
			var/datum/bioHolder/originalBHolder = new/datum/bioHolder(M)
			originalBHolder.CopyOther(M.bioHolder)
			absorbed_dna = list("[M.name]" = originalBHolder)

	proc/addDna(var/mob/living/carbon/human/M, var/headspider_override = 0)
		var/datum/abilityHolder/changeling/O = M.get_ability_holder(/datum/abilityHolder/changeling)
		if (O)
			boutput(owner, SPAN_NOTICE("[M] was a changeling! We have absorbed [his_or_her(M)] entire genetic structure!"))
			logTheThing(LOG_COMBAT, owner, "absorbs [constructTarget(M,"combat")] as a changeling [log_loc(owner)].")

			if (headspider_override != 1) // Headspiders shouldn't be free.
				src.points += M.dna_to_absorb // 10 regular points for their body...

			if (O.points > 0) // ...and then grab their DNA stockpile too.
				src.points = max(0, src.points + O.points)

			src.absorbtions++ // Same principle.
			for(var/D in O.absorbed_dna)
				src.absorbed_dna[D] = O.absorbed_dna[D]
				src.absorbtions++

			O.absorbed_dna = list()
			O.points = 0

			for(var/mob/H in O.hivemind)
				src.insert_into_hivemind(H)
			O.hivemind = list()

		/* LAGG NOTE:
			tailsnake, strangles people and attaches themselves to peoples butts and makes it hard to do stuff */

		else
			var/datum/bioHolder/originalBHolder = new/datum/bioHolder(M)
			originalBHolder.CopyOther(M.bioHolder)
			src.absorbed_dna[M.real_name] = originalBHolder

			if (headspider_override != 1)
				src.points += M.dna_to_absorb
			src.absorbtions++
		src.insert_into_hivemind(M)

	proc/insert_into_hivemind(var/mob/M)
		var/datum/mind/mind_to_be_transferred

		// Locate the mind of the mob to be inserted into the hivemind.
		if (M.mind)
			mind_to_be_transferred = M.mind
		else if (M.client)
			mind_to_be_transferred = M.client.mob.mind
		else if (M.ghost && (M.ghost.mind || M.ghost.client) && !M.ghost.mind.get_player().dnr)
			var/mob/dead/ghost = M.ghost
			ghost.show_text(SPAN_ALERT("You feel yourself torn away from the afterlife and into another consciousness!"))
			if(ghost.mind)
				mind_to_be_transferred = ghost.mind
			else if (ghost.client)
				mind_to_be_transferred = ghost.client.mob.mind

		// Last attempt to find a mind.
		else if (M.last_client)
			for (var/client/C in clients)
				if (C == M.last_client && C.mob && (isobserver(C.mob) || isVRghost(C.mob)))
					if(C.mob && C.mob.mind)
						mind_to_be_transferred = C.mob.mind

					break

		if (!mind_to_be_transferred)
			return

		// Remove changeling critter antagonist roles, as the mind is removed from the critter prior to death.
		for (var/datum/antagonist/antag in mind_to_be_transferred.antagonists)
			if (istype(antag, /datum/antagonist/subordinate/changeling_critter))
				mind_to_be_transferred.remove_antagonist(antag)

		// Remove any previous hivemind member roles, and add a new one.

		mind_to_be_transferred.remove_antagonist(ROLE_CHANGELING_HIVEMIND_MEMBER)
		mind_to_be_transferred.add_subordinate_antagonist(ROLE_CHANGELING_HIVEMIND_MEMBER, master = src.owner.mind)
		mind_to_be_transferred.current.show_antag_popup(ROLE_CHANGELING_HIVEMIND_MEMBER)
		return mind_to_be_transferred.current

	proc/return_control_to_master()
		if(master)
			var/datum/mind/changeling_master_mind = src.master.mind
			logTheThing(LOG_COMBAT, master, "has retaken control of the changeling body from [constructTarget(owner,"combat")].")
			//Return the controller to the hivemind, with their original names.
			boutput(src.owner,"<h2><span class='combat bold'>[master] has retaken control of the flesh!</span></h2>")
			src.owner.mind.transfer_to(temp_controller)
			temp_controller = null
			boutput(master, SPAN_NOTICE("We retake control of our form!"))
			changeling_master_mind.remove_antagonist(ROLE_CHANGELING_HIVEMIND_MEMBER)
			changeling_master_mind.transfer_to(owner)
			master = null
			return 1


	proc/reassign_hivemind_target_mob()
		if(src.owner)
			for (var/mob/dead/target_observer/hivemind_observer/O in src.hivemind)
				O.set_observe_target(src.owner)

	/// Get all hivemind members (including the changeling) who are still present
	proc/get_current_hivemind()
		. = list()
		for (var/mob/member in (hivemind + owner))
			if (isdead(member) || istype(member, /mob/living/critter/changeling) || (member == owner))
				. += member

	onAbilityStat()
		..()
		.= list()
		//On Changeling tab
		.["DNA:"] = round(points)
		.["Total:"] = absorbtions

	onAbilityHolderInstanceAdd()
		..()
		for(var/mob/dead/target_observer/hivemind_observer/HO in hivemind)
			src.insert_into_hivemind(HO)

// ----------------------------------------
// Generic abilities that critters may have
// ----------------------------------------

/datum/targetable/changeling
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "template" // No longer ToDo thanks to Sundance420.
	cooldown = 0
	last_cast = 0
	var/abomination_only = 0
	var/human_only = 0
	var/can_use_in_container = 0
	preferred_holder_type = /datum/abilityHolder/changeling

	proc/incapacitationCheck()
		var/mob/living/M = holder.owner
		var/datum/abilityHolder/changeling/H = holder
		if (istype(H) && H.in_fakedeath)
			return 1
		return M.stat || M.getStatusDuration("unconscious")

	castcheck()
		if (incapacitationCheck())
			boutput(holder.owner, SPAN_ALERT("We cannot use our abilities while incapacitated."))
			return 0
		if (!isturf(src.holder.owner.loc) && !src.can_use_in_container)
			boutput(src.holder.owner, SPAN_ALERT("You can't use this ability here."))
			return FALSE
		if (!human_only && !abomination_only)
			return 1
		var/mob/living/carbon/human/H = holder.owner
		if (istype(H))
			if (human_only && (isabomination(H) || ismonkey(H)))
				return 0
			else if (abomination_only && !isabomination(H))
				return 0
			else
				return 1//what could possibly go wrong
		return 0

	Stat()
		if (!human_only && !abomination_only)
			..()
		var/mob/living/carbon/human/H = holder.owner
		if (istype(H))
			if (human_only && !isabomination(H) && !ismonkey(H))
				..()
			else if (abomination_only && isabomination(H))
				..()

	display_available()
		.= 1
		if (human_only || abomination_only)
			.= 0
			var/mob/living/carbon/human/H = holder.owner
			if (istype(H))
				if (human_only && !isabomination(H) && !ismonkey(H))
					.= 1
				else if (abomination_only && isabomination(H))
					.= 1
