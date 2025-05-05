/datum/antagonist/conspirator
	id = ROLE_CONSPIRATOR
	antagonist_icon = "conspirator"
	display_name = "conspirator"
	wiki_link = "https://wiki.ss13.co/Conspirator"
	var/static/list/datum/mind/conspirators
	var/static/datum/objective/conspiracy/conspirator_objective
	var/static/meeting_point
	var/obj/item/device/radio/headset/headset

	New(datum/mind/new_owner)
		if (!src.conspirator_objective)
			var/objective_type = pick(typesof(/datum/objective/conspiracy))
			src.conspirator_objective = new objective_type

		if (!src.meeting_point)
			src.meeting_point = "Your initial meet-up point is <b>[pick("the chapel", "the bar", "disposals", "the arcade", "the escape wing", "crew quarters", "the pool", "the aviary")].</b>"

		if (!src.conspirators)
			src.conspirators = list()

		src.owner = new_owner
		src.conspirators += src.owner
		for (var/datum/mind/conspirator in src.conspirators)
			SEND_SIGNAL(conspirator, COMSIG_MIND_UPDATE_MEMORY)

		. = ..()

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return
		var/mob/living/carbon/human/H = src.owner.current

		// If possible, get the conspirator's headset.
		if (istype(H.ears, /obj/item/device/radio/headset))
			src.headset = H.ears
		else
			src.headset = new /obj/item/device/radio/headset(H)
			if (!H.r_store)
				H.equip_if_possible(src.headset, SLOT_R_STORE)
			else if (!H.l_store)
				H.equip_if_possible(src.headset, SLOT_L_STORE)
			else if (H.back?.storage && !H.back.storage.is_full())
				H.equip_if_possible(src.headset, SLOT_IN_BACKPACK)
			else
				H.put_in_hand_or_drop(src.headset)

		src.headset.install_radio_upgrade(new /obj/item/device/radio_upgrade/conspirator)

	remove_equipment()
		src.headset.remove_radio_upgrade()

	assign_objectives()
		new /datum/objective/conspiracy(src.conspirator_objective.explanation_text, src.owner, src)

		SPAWN(1 SECOND)
			src.owner.store_memory(src.meeting_point)
			boutput(src.owner.current, src.meeting_point)

			var/datum/dynamic_player_memory/conspirator_list/conspirator_list_memory = new(src.owner)
			src.owner.dynamic_memories += conspirator_list_memory
			boutput(src.owner.current, conspirator_list_memory.memory_text)

	remove_self()
		src.conspirators -= src.owner
		src.owner.remove_dynamic_memories_by_type(/datum/dynamic_player_memory/conspirator_list)
		for (var/datum/mind/conspirator in src.conspirators)
			SEND_SIGNAL(conspirator, COMSIG_MIND_UPDATE_MEMORY)
		. = ..()
