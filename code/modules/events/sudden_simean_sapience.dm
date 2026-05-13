/datum/random_event/major/player_spawn/sudden_sapience_disease
	name = "Sudden Sapience Disease"
	required_elapsed_round_time = 10 MINUTES
	required_npc_type = /mob/living/carbon/human/npc/monkey/
	var/ghost_confirmation_delay = 1 MINUTES
	var/list/eligible_npc_list = list()

	admin_call(var/source)
		if (..())
			return

		switch (alert(usr, "Which NPCs should be targeted?", src.name, "Monkeys", "All", "Custom"))
			if ("Monkeys")
				src.required_npc_type =	/mob/living/carbon/human/npc/monkey/
			if ("All")
				src.required_npc_type = /mob/living/carbon/human/npc/
			if ("Custom")
				src.required_npc_type = input("Enter a mob path or partial name", src.name, null) as null|text

	event_effect(var/source)
		..()
		src.eligible_npc_list = find_all_by_type(required_npc_type)
		if (!src.eligible_npc_list)
			return
		var/mob/picked_monkey = pick(src.eligible_npc_list)

		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as [picked_monkey.name]?")
		text_messages.Add("You are eligible to be respawned as [picked_monkey.name]. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the monkey list. Please wait...")

		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1, for_antag = FALSE)

		if (!candidates)
			message_ghosts("No monkeys became sapient.")
			return

		var/datum/mind/M = pick(candidates)
		if (M.current)
			if(!isobserver(M.current))
				M.current.ghostize()
			log_respawn_event(M, "random station monkey", source)
			M.transfer_to(picked_monkey)
			message_ghosts("<b>[picked_monkey.name] has become sapient.</b>")
		candidates -= M
