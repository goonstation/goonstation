/datum/antagonist/subordinate/hivemind_member
	id = ROLE_CHANGELING_HIVEMIND_MEMBER
	display_name = "changeling hivemind member"
	remove_on_clone = TRUE
	wiki_link = "https://wiki.ss13.co/Changeling"

	give_equipment()
		var/datum/abilityHolder/changeling/master_ability_holder = src.master.current.get_ability_holder(/datum/abilityHolder/changeling)
		var/mob/current_mob = src.owner.current
		var/mob/dead/target_observer/hivemind_observer/hivemind_observer = new/mob/dead/target_observer/hivemind_observer(src.master.current)
		hivemind_observer.name = src.owner.current.name
		hivemind_observer.real_name = src.owner.current.real_name

		if (src.master.current.invisibility)
			hivemind_observer.see_invisible = src.master.current.invisibility

		// Corpse and ghost handling.
		if (istype(current_mob, /mob/living/carbon))
			current_mob.ghost = null
		else if (istype(current_mob, /mob/dead))
			var/mob/dead/dead_mob = current_mob
			dead_mob.corpse?.ghost = null
			dead_mob.corpse = null
			hivemind_observer.corpse = null
		else if (istype(current_mob, /mob/living/critter/changeling))
			hivemind_observer.corpse = current_mob
			current_mob.ghost = hivemind_observer

		src.owner.transfer_to(hivemind_observer)

		hivemind_observer.set_owner(master_ability_holder)

		src.owner.current.ensure_speech_tree().AddSpeechOutput(SPEECH_OUTPUT_HIVECHAT_MEMBER, subchannel = "\ref[master_ability_holder]")
		src.owner.current.default_speech_output_channel = SAY_CHANNEL_HIVEMIND

	remove_equipment()
		var/mob/dead/target_observer/hivemind_observer/hivemind_observer = src.owner.current
		var/mob/dead/observer/ghost_mob = src.owner.current.ghostize()

		if (!hivemind_observer.corpse)
			ghost_mob.name = hivemind_observer.name
			ghost_mob.real_name = hivemind_observer.real_name
		else
			hivemind_observer.corpse.ghost = ghost_mob
			ghost_mob.corpse = hivemind_observer.corpse
		if (hivemind_observer.hivemind_owner)
			hivemind_observer.hivemind_owner.hivemind -= hivemind_observer
		LAZYLISTREMOVE(hivemind_observer.observers, hivemind_observer)
		qdel(hivemind_observer)

	announce_objectives()
		return

	announce()
		return

	announce_removal()
		if (src.owner != src.master)
			src.owner.current.show_antag_popup("changeling_leave")

	do_popup()
		return
