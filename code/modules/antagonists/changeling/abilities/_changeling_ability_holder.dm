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
			absorbed_dna = list("[M.name]" = new /datum/absorbedIdentity(M))

	onAttach(mob/to_whom)
		. = ..()
		RegisterSignal(to_whom, COMSIG_MOB_DEATH, PROC_REF(on_death), TRUE)
		to_whom.ensure_speech_tree().AddSpeechOutput(SPEECH_OUTPUT_HIVECHAT_MEMBER, subchannel = ref(src))
		to_whom.ensure_listen_tree().AddListenInput(LISTEN_INPUT_HIVECHAT, subchannel = ref(src))

	onRemove(mob/from_who)
		. = ..()

		if (from_who)
			from_who.ensure_speech_tree().RemoveSpeechOutput(SPEECH_OUTPUT_HIVECHAT_MEMBER, subchannel = ref(src))
			from_who.ensure_listen_tree().RemoveListenInput(LISTEN_INPUT_HIVECHAT, subchannel = ref(src))

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
			src.absorbed_dna[M.real_name] = new /datum/absorbedIdentity(M)

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

	proc/on_death(mob/mobref, gibbed)
		var/mob/living/carbon/human/body = src.owner
		if (gibbed || src.points < 10)
			if (src.points < 10)
				boutput(body, "You try to release a headspider but don't have enough DNA points (requires 10)!")
			for (var/mob/living/critter/changeling/spider in src.hivemind)
				boutput(spider, SPAN_ALERT("Your telepathic link to your master has been destroyed!"))
				spider.hivemind_owner = 0
			for (var/mob/dead/target_observer/hivemind_observer/obs in src.hivemind)
				boutput(obs, SPAN_ALERT("Your telepathic link to your master has been destroyed!"))
				obs.mind?.remove_antagonist(ROLE_CHANGELING_HIVEMIND_MEMBER)
			if (length(src.hivemind) > 0)
				boutput(body, "Contact with the hivemind has been lost.")
			src.hivemind = list()
			if(src.master != src.temp_controller)
				src.return_control_to_master()

		else
			//Changelings' heads pop off and crawl away - but only if they're not gibbed and have some spare DNA points. Oy vey!
			body.emote("deathgasp", dead_check = FALSE)
			body.visible_message(SPAN_ALERT("<B>[body]</B>'s head starts to shift around!"))
			body.show_text("<b>We begin to grow a headspider...</b>", "blue")
			var/mob/living/critter/changeling/headspider/HS = new /mob/living/critter/changeling/headspider(body) //we spawn the headspider inside this dude immediately.
			HS.RegisterSignal(body, COMSIG_PARENT_PRE_DISPOSING, TYPE_PROC_REF(/mob/living/critter/changeling/headspider, remove)) //if this dude gets grindered or cremated or whatever, we go with it
			body.mind?.transfer_to(HS) //ok we're a headspider now
			HS.ensure_speech_tree().AddSpeechOutput(SPEECH_OUTPUT_HIVECHAT_MEMBER, subchannel = "\ref[src]")
			HS.ensure_listen_tree().AddListenInput(LISTEN_INPUT_HIVECHAT, subchannel = "\ref[src]")
			HS.default_speech_output_channel = SAY_CHANNEL_HIVEMIND
			src.points = max(0, src.points - 10) // This stuff isn't free, you know.
			HS.changeling = src
			// alright everything to do with headspiders is a blasted hellscape but here's what goes on here
			// we don't want to actually give the headspider access to the changeling abilityholder, because that would let it use all the abilities
			// which leads to bugs and is generally bad. So we remove the HUD from corpsey over here, tell the abilityholder that the headspider owns it,
			// but we do NOT tell the headspider it has access to the abilities.
			body.detach_hud(src.hud)
			src.owner = HS
			src.reassign_hivemind_target_mob()
			sleep(20 SECONDS)
			if (HS.disposed || !HS.mind || HS.mind.disposed || isdead(HS)) // we went somewhere else, or suicided, or something idk
				return
			HS.UnregisterSignal(body, COMSIG_PARENT_PRE_DISPOSING) // We no longer want to disappear if the body gets del'd
			boutput(HS, "<b class = 'hint'>We released a headspider, using up some of our DNA reserves.</b>")
			HS.set_loc(get_turf(body)) //be free!!!
			body.visible_message(SPAN_ALERT("<B>[body]</B>'s head detaches, sprouts legs and wanders off looking for food!"))
			// make a headspider, have it crawl to find a host, give the host the disease, hand control to the player again afterwards
			body.remove_ability_holder(/datum/abilityHolder/changeling/)

			if (body.client)
				body.ghostize()
				boutput(src.owner, "Something went wrong, and we couldn't transfer you into a handspider! Please adminhelp this.")

			logTheThing(LOG_COMBAT, body, "became a headspider at [log_loc(body)].")

			// unequip head items
			for (var/obj/item/item in list(body.wear_mask, body.glasses, body.head, body.ears))
				if (item)
					body.u_equip(item)
					item.set_loc(body.loc)

			var/obj/item/organ/head/organ_head = body.organHolder.drop_organ("head")
			qdel(organ_head)

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

///A stored representation of an absorbed victim, we load their traits as well as their bioholder now
/datum/absorbedIdentity
	var/name
	var/datum/bioHolder/bioHolder
	var/datum/traitHolder/traitHolder

	New(mob/M)
		if (M)
			src.set_up_from(M)
		. = ..()

	proc/set_up_from(mob/living/carbon/human/victim)
		//lol this is so nonstandardized I want to cry
		src.bioHolder = new /datum/bioHolder(victim)
		src.bioHolder.CopyOther(victim.bioHolder)

		src.traitHolder = new /datum/traitHolder(victim)
		victim.traitHolder.copy_to(src.traitHolder)

		src.name = victim.real_name
		victim.UpdateName()

	proc/apply_to(mob/living/carbon/human/human)
		human.bioHolder.CopyOther(src.bioHolder)
		src.traitHolder.copy_to(human.traitHolder)

		human.bioHolder.RemoveEffect("husk")
		human.real_name = src.name
		human.organHolder.head.UpdateIcon()
		if (human.bioHolder?.mobAppearance?.mutant_race)
			human.set_mutantrace(human.bioHolder.mobAppearance.mutant_race.type)
		else
			human.set_mutantrace(null)
		human.update_face()
		human.update_body()
		human.update_clothing()

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
