ABSTRACT_TYPE(/datum/antagonist/subordinate/changeling_critter)
/datum/antagonist/subordinate/changeling_critter
	remove_on_death = TRUE
	remove_on_clone = TRUE
	antagonist_icon = "changeling"
	wiki_link = "https://wiki.ss13.co/Changeling#The_Hivemind"
	var/critter_type = null
	var/speech_output = SPEECH_OUTPUT_HIVECHAT
	var/datum/abilityHolder/changeling/master_ability_holder

	give_equipment()
		src.master_ability_holder = src.master?.current?.get_ability_holder(/datum/abilityHolder/changeling)
		if (!src.master_ability_holder)
			return

		var/obj/item/bodypart
		for (var/datum/targetable/changeling/critter/ability in src.master_ability_holder.abilities)
			if (ability.antag_role == src.id)
				bodypart = ability.get_bodypart()
				break

		var/mob/old_mob = src.owner.current
		var/turf/spawn_loc = get_turf(master_ability_holder?.owner) || get_turf(src.owner.current)
		var/mob/living/critter/changeling/critter = new src.critter_type(spawn_loc, bodypart)

		src.master_ability_holder.hivemind -= old_mob
		src.master_ability_holder.hivemind += critter
		critter.hivemind_owner = src.master_ability_holder
		src.owner.transfer_to(critter)
		qdel(old_mob)

		src.owner.current.ensure_speech_tree().AddSpeechOutput(src.speech_output, subchannel = "\ref[src.master_ability_holder]")
		src.owner.current.ensure_listen_tree().AddListenInput(LISTEN_INPUT_HIVECHAT, subchannel = "\ref[src.master_ability_holder]")
		src.owner.current.default_speech_output_channel = SAY_CHANNEL_HIVEMIND

	remove_equipment()
		src.master_ability_holder.hivemind -= src.owner.current

		src.owner.current.ensure_speech_tree().RemoveSpeechOutput(src.speech_output, subchannel = "\ref[src.master_ability_holder]")
		src.owner.current.ensure_listen_tree().RemoveListenInput(LISTEN_INPUT_HIVECHAT, subchannel = "\ref[src.master_ability_holder]")
		src.owner.current.default_speech_output_channel = null

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.master_ability_holder)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.master_ability_holder)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	announce()
		var/mob/living/critter/changeling/critter = src.owner.current
		if (!istype(critter))
			return ..()
		boutput(src.owner.current, "<h3>[SPAN_ALERT("You have reawakened to serve your host changeling, [src.master.current.real_name]! You must follow [his_or_her(src.master.current)] commands!")]</h3>")

	announce_removal()
		return

	announce_objectives()
		return
/datum/antagonist/subordinate/changeling_critter/handspider
	id = ROLE_HANDSPIDER
	display_name = "handspider"
	critter_type = /mob/living/critter/changeling/handspider
	speech_output = SPEECH_OUTPUT_HIVECHAT_HANDSPIDER

	announce()
		..()
		boutput(src.owner.current, SPAN_ALERT("You are a very small and weak creature that can fit into tight spaces. You are still connected to the hivemind."))

/datum/antagonist/subordinate/changeling_critter/eyespider
	id = ROLE_EYESPIDER
	display_name = "eyespider"
	critter_type = /mob/living/critter/changeling/eyespider
	speech_output = SPEECH_OUTPUT_HIVECHAT_EYESPIDER

	announce()
		..()
		boutput(src.owner.current, SPAN_ALERT("You are a very small and weak creature that can fit into tight spaces, and see through walls. You are still connected to the hivemind."))

/datum/antagonist/subordinate/changeling_critter/legworm
	id = ROLE_LEGWORM
	display_name = "legworm"
	critter_type = /mob/living/critter/changeling/legworm
	speech_output = SPEECH_OUTPUT_HIVECHAT_LEGWORM

	announce()
		..()
		boutput(src.owner.current, SPAN_ALERT("You are a small creature that can deliver powerful kicks and fit into tight spaces. You are still connected to the hivemind."))

/datum/antagonist/subordinate/changeling_critter/buttcrab
	id = ROLE_BUTTCRAB
	display_name = "buttcrab"
	critter_type = /mob/living/critter/changeling/buttcrab
	speech_output = SPEECH_OUTPUT_HIVECHAT_BUTTCRAB

	announce()
		..()
		boutput(src.owner.current, SPAN_ALERT("You are a very small, very smelly, and weak creature. You are still connected to the hivemind."))
