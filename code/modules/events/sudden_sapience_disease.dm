/datum/random_event/major/player_spawn/sudden_sapience_disease
	name = "Sudden Sapience Disease"
	required_elapsed_round_time = 10 MINUTES
	required_npc_type = /mob/living/carbon/human/npc/monkey
	weight = 60
	var/ghost_confirmation_delay = 1 MINUTES
	var/list/antag_npcs = list(/mob/living/carbon/human/npc/monkey/stirstir, /mob/living/carbon/human/npc/monkey/oppenheimer)

	proc/pick_npc()
		var/list/mob/found_npcs = list()
		for_by_tcl(monke, /mob/living/carbon/human/npc/monkey)
			var/turf/monkearea = get_turf(monke)
			if (istype(monkearea.loc, /area/station/medical/dome) || istype(monke, /mob/living/carbon/human/npc/monkey/angry) || monke.mind?.current.client)
				continue // remove monkey pen apes so you don't get one of those 95% of the time

			if (isalive(monke) && get_z(monke) == Z_LEVEL_STATION)
				found_npcs += monke

		if (prob(5))
			var/mob/bigbill = locate(/mob/living/carbon/human/biker)
			if (isalive(bigbill))
				found_npcs += bigbill // hehe

		if (length(found_npcs) <= 0)
			return
		return pick(found_npcs)

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

		if (!picked_npc || picked_npc.mind?.current.client || !isalive(picked_npc))
			picked_npc = src.pick_npc() // last second check, reroll monkey if the one you picked somehow gained a mind between the vote and the spawn, or died

		if (length(candidates) > 0)
			var/datum/mind/M = pick(candidates)
			if (M.current)
				if(!isobserver(M.current))
					M.current.ghostize()
				log_respawn_event(M, "random station monkey", source)
				M.transfer_to(picked_npc)
				SPAWN(0)
					if (istype(picked_npc, /mob/living/carbon/human/biker))
						tgui_alert(picked_npc, "You are not an antagonist! While you are not employed by NanoTrasen, you should still act like a somewhat sane person that doesn't want to die or hurt people.", "You are not an antagonist!")
					else if (istypes(picked_npc, src.antag_npcs))
						M.add_antagonist(ROLE_SYNDICATE_MONKEY, source = ANTAGONIST_SOURCE_RANDOM_EVENT)
						message_admins("[key_name(M)] awakened as a syndicate agent monkey. Source: [source ? "[source]" : "random event"]")
						logTheThing(LOG_ADMIN, M, "awakened as a syndicate agent monkey. Source: [source ? "[source]" : "random event"]")
					else
						tgui_alert(picked_npc, "You are not an antagonist! Humans can't understand you, but a vocal translator can change that.", "You are not an antagonist!")
				message_ghosts("<b>[picked_npc.real_name] has become sapient.</b>")
