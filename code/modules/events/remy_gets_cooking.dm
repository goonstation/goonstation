/datum/random_event/major/player_spawn/remy_gets_cooking
	name = "Remy Must Cook"
	required_elapsed_round_time = 10 MINUTES
	required_npc_type = /mob/living/critter/small_animal/mouse/remy

#ifdef HALLOWEEN
	weight = 150
#else
	weight = 80
#endif
	var/ghost_confirmation_delay = 1 MINUTES

	event_effect(var/source)
		..()
		var/mob/picked_npc = locate(/mob/living/critter/small_animal/mouse/remy)
		if (QDELETED(picked_npc) || !isalive(picked_npc))
			return
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as [picked_npc.real_name]?")
		text_messages.Add("You are eligible to be respawned as [picked_npc.real_name]. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the NPC list. Please wait...")

		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1, for_antag = FALSE)

		if (QDELETED(picked_npc) || picked_npc.mind?.current.client || !isalive(picked_npc))
			return

		if (length(candidates) > 0)
			var/datum/mind/M = pick(candidates)
			if (M.current)
				if(!isobserver(M.current))
					M.current.ghostize()
				log_respawn_event(M, "remy", source)
				M.transfer_to(picked_npc)
				SPAWN(0)
					tgui_alert(picked_npc, "You are not an antagonist! What you are, is a chef. Get to work.", "You are not an antagonist!")
				message_ghosts("<b>[picked_npc.real_name] has become sapient.</b>")
