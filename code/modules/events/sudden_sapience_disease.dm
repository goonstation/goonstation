/datum/random_event/major/player_spawn/sudden_sapience_disease
	name = "Sudden Sapience Disease"
	required_elapsed_round_time = 10 MINUTES
	required_npc_type = /mob/living/carbon/human/npc/monkey
	var/ghost_confirmation_delay = 1 MINUTES
	var/list/npc_blacklist = list(/mob/living/carbon/human/npc/monkey/stirstir, /mob/living/carbon/human/npc/monkey/oppenheimer, /mob/living/carbon/human/npc/monkey/angry/, /mob/living/carbon/human/npc/diner_bartender/)

	proc/pick_npc()
		var/list/mob/found_npcs = list()
		for (var/mob/living/carbon/human/npc/monkey/monke in world)
			if (istypes(monke, src.npc_blacklist))
				continue
			var/turf/monkearea = get_turf(monke)
			if (istype(monkearea.loc, /area/station/medical/dome)) // remove monkey pen apes so you don't get one of those 95% of the time
				found_npcs -= monke // maybe game-able? dunno why someone would
				continue
			found_npcs += monke

		if (prob(5))
			found_npcs += locate(/mob/living/carbon/human/biker) // hehe

		var/mob/proposed_npc = pick(found_npcs)

		if (isalive(proposed_npc))
			return proposed_npc

	event_effect(var/source)
		..()
		var/mob/picked_npc = src.pick_npc()
		if (!picked_npc)
			return
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as [picked_npc.real_name]?")
		text_messages.Add("You are eligible to be respawned as [picked_npc.real_name]. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the NPC list. Please wait...")

		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1, for_antag = FALSE)

		if (candidates.len > 0)
			var/datum/mind/M = pick(candidates)
			if (M.current)
				if(!isobserver(M.current))
					M.current.ghostize()
				log_respawn_event(M, "random station monkey", source)
				M.transfer_to(picked_npc)
				message_ghosts("<b>[picked_npc.real_name] has become sapient.</b>")
		else
			message_ghosts("No NPCs became sapient.")
			return
