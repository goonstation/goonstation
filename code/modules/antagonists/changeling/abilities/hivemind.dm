//since I have now unfucked this file, here are what each successive person who copy pasted the same ability code had to say for themselves:
// feels bad copy-pasting this, maybe refactor this in future - cirr
// oh what's this? I copypasted it again, ooopsy! maybe refactor this in future  - mbc
// Oh fuck. Did I copy paste this yet again? Damn. Maybe one day we'll get around to refactoring this. -fire

ABSTRACT_TYPE(/datum/targetable/changeling/critter)
/datum/targetable/changeling/critter
	cooldown = 600
	targeted = 0
	target_anything = 0
	human_only = 0
	can_use_in_container = 1
	///The observer mob we chose to transfer mind from, this should just be returned from New, but datum/targetable/New relies on truthy fail states
	var/mob/dead/target_observer/hivemind_observer/use_mob = null
	///The associated ROLE_ define
	var/antag_role = null

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return TRUE

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, SPAN_ALERT("That ability is incompatible with our abilities. We should report this to a coder."))
			return TRUE

		//Verify that you are not in control of your master's body.
		if(H.master && H.owner != H.master)
			boutput(holder.owner, SPAN_ALERT("A member of the hivemind cannot release a sub-form!."))
			return TRUE

		var/list/eligible = list()
		for (var/mob/dead/target_observer/hivemind_observer/O in H.hivemind)
			if (O.client)
				eligible[O.real_name] = O

		if (length(eligible) < 1)
			boutput(holder.owner, SPAN_ALERT("There are no minds eligible for this ability. We need to absorb another."))
			return TRUE

		var/use_mob_name = tgui_input_list(holder.owner, "Select the mind to transfer into the handspider:", "Select Mind", sortList(eligible, /proc/cmp_text_asc))
		if (!use_mob_name)
			boutput(holder.owner, SPAN_NOTICE("We change our mind."))
			return TRUE

		src.use_mob = eligible[use_mob_name]

		if (!src.available_bodypart())
			return TRUE

		var/datum/mind/mind = use_mob.mind
		if (!mind)
			logTheThing(LOG_DEBUG, holder.owner, "tries to spawn a changeling critter from a mob with no mind. THIS SHOULD NEVER HAPPEN AND MAY BREAK THINGS.")
			return TRUE
		mind.remove_antagonist(ROLE_CHANGELING_HIVEMIND_MEMBER)
		mind.add_subordinate_antagonist(src.antag_role, source = ANTAGONIST_SOURCE_SUMMONED, master = src.holder.owner.mind)
		logTheThing(LOG_COMBAT, holder.owner, "drops \an [src.antag_role] [key_name(mind.current)] as a changeling [log_loc(src.holder.owner)].")

		return FALSE

	proc/available_bodypart()
		return

	proc/get_bodypart()
		return

/datum/targetable/changeling/critter/handspider
	name = "Handspider"
	desc = "Detach one of your arms and bring it to life using one of the members of your hivemind."
	icon_state = "handspider"
	pointCost = CHANGELING_HANDSPIDER_COST
	antag_role = ROLE_HANDSPIDER

	available_bodypart()
		var/mob/living/carbon/human/owner = holder.owner
		if (!(owner.limbs.l_arm || owner.limbs.r_arm) || !ishuman(holder.owner))
			return FALSE

		return TRUE

	get_bodypart()
		var/mob/living/carbon/human/owner = holder.owner
		if (!src.available_bodypart())
			boutput(holder.owner, SPAN_NOTICE("We have no arms to detach!"))
			return null

		var/obj/item/parts/original_arm = null

		if (owner.limbs.l_arm && owner.limbs.r_arm) //if both arms are available, remove the inactive one
			if (owner.hand)
				original_arm = owner.limbs.r_arm.remove(FALSE)
				owner.changeStatus("c_regrow-r_arm", 75 SECONDS)
			else
				original_arm = owner.limbs.l_arm.remove(FALSE)
				owner.changeStatus("c_regrow-l_arm", 75 SECONDS)
		else if (owner.limbs.l_arm)
			original_arm = owner.limbs.l_arm.remove(FALSE)
			owner.changeStatus("c_regrow-l_arm", 75 SECONDS)
		else
			original_arm = owner.limbs.r_arm.remove(FALSE)
			owner.changeStatus("c_regrow-r_arm", 75 SECONDS)

		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner]'s arm falls off and starts moving!</B>"))

		return original_arm

/datum/targetable/changeling/critter/eyespider
	name = "Eyespider"
	desc = "Eject one of your eyes as a non-combatant utility form and bring it to life using one of the members of your hivemind."
	icon_state = "eyespider"
	pointCost = CHANGELING_EYESPIDER_COST
	antag_role = ROLE_EYESPIDER

	available_bodypart()
		var/mob/living/carbon/human/owner = holder.owner
		if (!(owner.organHolder.left_eye || owner.organHolder.right_eye) || !ishuman(holder.owner))
			return FALSE

		return TRUE

	get_bodypart()
		var/mob/living/carbon/human/owner = holder.owner
		if (!src.available_bodypart())
			boutput(holder.owner, SPAN_NOTICE("We have no eyes to eject!")) // what a terrifying fate you've given yourself
			return null

		var/original_eye = null

		if (owner.organHolder.left_eye && owner.organHolder.right_eye) // if both eyes are available, pick one at random
			if (prob(50))
				original_eye = owner.drop_organ("left_eye")
				owner.changeStatus("c_regrow-l_eye", 40 SECONDS)
			else
				original_eye = owner.drop_organ("right_eye")
				owner.changeStatus("c_regrow-r_eye", 40 SECONDS)
		else if (owner.organHolder.left_eye)
			original_eye = owner.drop_organ("left_eye")
			owner.changeStatus("c_regrow-l_eye", 40 SECONDS)
		else
			original_eye = owner.drop_organ("right_eye")
			owner.changeStatus("c_regrow-r_eye", 40 SECONDS)

		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner]'s eye shoots out and starts moving!</B>"))

		return original_eye

/datum/targetable/changeling/critter/legworm
	name = "Legworm"
	desc = "Detach one of your legs and bring it to life using one of the members of your hivemind."
	icon_state = "legworm"
	cooldown = 1200
	pointCost = CHANGELING_LEGWORM_COST
	antag_role = ROLE_LEGWORM

	available_bodypart()
		var/mob/living/carbon/human/owner = holder.owner
		if (!(owner.limbs.l_leg || owner.limbs.r_leg) || !ishuman(holder.owner))
			return FALSE

		return TRUE

	get_bodypart()
		var/mob/living/carbon/human/owner = holder.owner
		if (!src.available_bodypart())
			boutput(holder.owner, SPAN_NOTICE("We have no legs to detach!"))
			return null

		var/obj/item/parts/original_leg = null

		if (owner.limbs.l_leg && owner.limbs.r_leg) //remove leg opposite of active hand
			if (owner.hand)
				original_leg = owner.limbs.r_leg.remove()
				owner.changeStatus("c_regrow-r_leg", 75 SECONDS)
			else
				original_leg = owner.limbs.l_leg.remove()
				owner.changeStatus("c_regrow-l_leg", 75 SECONDS)
		else if (owner.limbs.l_leg)
			original_leg = owner.limbs.l_leg.remove()
			owner.changeStatus("c_regrow-l_leg", 75 SECONDS)
		else
			original_leg = owner.limbs.r_leg.remove()
			owner.changeStatus("c_regrow-r_leg", 75 SECONDS)

		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner]'s leg falls off and starts moving!</B>"))

		return original_leg

/datum/targetable/changeling/critter/buttcrab
	name = "Buttcrab"
	desc = "You butt fall off and hivemind person become butt"
	icon_state = "buttcrab"
	cooldown = 600
	pointCost = CHANGELING_BUTTCRAB_COST
	antag_role = ROLE_BUTTCRAB

	available_bodypart()
		var/mob/living/carbon/human/owner = holder.owner
		if (!(owner.organHolder.butt) || !ishuman(holder.owner))
			return FALSE

		return TRUE

	get_bodypart()
		var/mob/living/carbon/human/owner = holder.owner
		if (!src.available_bodypart())
			boutput(holder.owner, SPAN_NOTICE("We have no ass!")) // what a terrifying fate you've given yourself
			return null

		var/obj/item/clothing/head/butt/original_butt = owner.drop_organ("butt")
		owner.changeStatus("c_regrow-butt", 40 SECONDS)

		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner]'s butt falls off and starts moving!</B>"))

		return original_butt


/datum/targetable/changeling/hivesay
	name = "Speak Hivemind"
	desc = "Speak to your own collected minds telepathically."
	icon_state = "hivesay"
	cooldown = 0
	targeted = 0
	target_anything = 0
	human_only = 0
	can_use_in_container = 1
	interrupt_action_bars = 0
	lock_holder = FALSE
	do_logs = FALSE
	interrupt_action_bars = FALSE

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return TRUE

		var/message = html_encode(tgui_input_text(usr, "Choose something to say:", "Enter Message."))
		if (!message)
			return

		src.holder.owner.say(message, flags = SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_HIVEMIND))
		return FALSE

/datum/targetable/changeling/boot
	name = "Silence Hivemind Member"
	desc = "Remove a member of your hivemind at no penalty."
	icon_state = "silence"
	cooldown = 0
	targeted = 0
	target_anything = 0
	human_only = 0
	pointCost = 0
	can_use_in_container = 1
	lock_holder = FALSE
	interrupt_action_bars = 0

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1
		var/datum/abilityHolder/changeling/H = holder
		//Sanity check
		if (!istype(H))
			boutput(holder.owner, SPAN_ALERT("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		//Verify that you are not in control of your master's body.
		if(H.master && H.owner != H.master)
			boutput(holder.owner, SPAN_ALERT("A member of the hivemind cannot boot other members of the hivemind!."))
			return 1

		var/list/eligible = list()
		for (var/mob/dead/target_observer/hivemind_observer/O in H.hivemind)
			eligible[O.real_name] = O

		if (length(eligible) < 1)
			boutput(holder.owner, SPAN_ALERT("There are no minds eligible for this ability."))
			return 1

		var/use_mob_name = tgui_input_list(holder.owner, "Select the mind to silence:", "Select Mind", sortList(eligible, /proc/cmp_text_asc))
		if (!use_mob_name)
			boutput(holder.owner, SPAN_NOTICE("We change our mind."))
			return 1

		//RIP
		var/mob/dead/target_observer/hivemind_observer/use_mob = eligible[use_mob_name]
		H.hivemind -= use_mob
		boutput(use_mob, SPAN_ALERT("You have been cut off from the hivemind by [holder.owner.real_name]!"))
		use_mob.mind?.remove_antagonist(ROLE_CHANGELING_HIVEMIND_MEMBER)
		boutput(holder.owner, SPAN_ALERT("You have silenced [use_mob_name]'s consciousness from your hivemind."))
		return 0


/datum/targetable/changeling/give_control
	name = "Grant Control to Hivemind Member"
	desc = "Allow one of the members of the hive mind to control our form."
	icon_state = "givecontrol"
	cooldown = 0
	targeted = 0
	target_anything = 0
	human_only = 0
	pointCost = 0
	can_use_in_container = 1
	lock_holder = FALSE
	interrupt_action_bars = 0

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1
		var/datum/abilityHolder/changeling/H = holder
		//Sanity check
		if (!istype(H))
			boutput(holder.owner, SPAN_ALERT("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		//Verify that you are not in control of your master's body.
		if(H.master && H.owner != H.master)
			boutput(holder.owner, SPAN_ALERT("A member of the hivemind cannot relinquish control of the shared form!."))
			return 1

		var/list/eligible = list()
		for (var/mob/dead/target_observer/hivemind_observer/O in H.hivemind)
			if(O.client)
				eligible += O

		if (length(eligible) < 1)
			boutput(holder.owner, SPAN_ALERT("There are no minds eligible for this ability."))
			return 1

		var/mob/dead/target_observer/hivemind_observer/HO = tgui_input_list(holder.owner, "Select the mind to grant control:", "Select Mind", sortList(eligible, /proc/cmp_text_asc))
		if(!HO)
			boutput(holder.owner, SPAN_NOTICE("We change our mind."))
			return TRUE
		if (!(HO in eligible))
			boutput(holder.owner, SPAN_ALERT("Something fucked up, ahelp about this. Mind transfer aborted."))
			stack_trace("[holder.owner] tried to grant control of a changeling body to [HO], but that name wasn't in the list of eligible mobs. List of mobs: [json_encode(eligible)]")
			return TRUE

		//Do the actual control-granting here.
		logTheThing(LOG_COMBAT, holder.owner, "granted control of their body to [constructTarget(HO,"combat")] as a changeling!")
		//Transfer the owner's mind into a hivemind observer and grant it the recovery verb
		var/mob/dead/target_observer/hivemind_observer/master = H.insert_into_hivemind(H.owner)
		master.verbs += /mob/dead/target_observer/hivemind_observer/proc/regain_control
		H.master = master //Make it the controller of the mob
		boutput(master, SPAN_NOTICE("We relinquish control of our form to [HO]!"))

		//Transfer the hivemind member's mind into the body.
		H.original_controller_name = HO.name
		H.original_controller_real_name = HO.real_name
		HO.mind.transfer_to(H.owner)
		H.transferOwnership(H.owner)
		H.temp_controller = HO

		boutput(H.owner, "<h1>[SPAN_ALERT("You have reawakened to serve your host [H.master]! You must follow [his_or_her(H.master)] commands and protect our form!")]</h1>")
