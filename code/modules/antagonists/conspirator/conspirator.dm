/datum/antagonist/conspirator
	id = ROLE_CONSPIRATOR
	display_name = "conspirator"

	var/static/list/datum/mind/conspirators
	var/static/conspirator_objective
	var/static/meeting_point
	var/obj/item/device/radio/headset/headset

	New(datum/mind/new_owner)
		if (!src.conspirator_objective)
			src.conspirator_objective = pick(typesof(/datum/objective/conspiracy))

		if (!src.meeting_point)
			src.meeting_point = "Your initial meet-up point is <b>[pick("the chapel", "the bar", "disposals", "the arcade", "the escape wing", "crew quarters", "the pool", "the aviary")].</b>"

		if (!src.conspirators)
			src.conspirators = list()

		src.owner = new_owner
		src.conspirators += src.owner
		for (var/datum/mind/conspirator in src.conspirators)
			SEND_SIGNAL(conspirator, COMSIG_MIND_UPDATE_MEMORY)

		. = ..()

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
				H.equip_if_possible(src.headset, H.slot_r_store)
			else if (!H.l_store)
				H.equip_if_possible(src.headset, H.slot_l_store)
			else if (istype(H.back, /obj/item/storage/) && H.back.contents.len < 7)
				H.equip_if_possible(src.headset, H.slot_in_backpack)
			else
				H.put_in_hand_or_drop(src.headset)

		src.headset.install_radio_upgrade(new /obj/item/device/radio_upgrade/conspirator)

	remove_equipment()
		src.headset.remove_radio_upgrade()

	do_popup(override)
		if (!override)
			override = "conspiracy"

		..(override)

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, src.conspirator_objective, src)

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
