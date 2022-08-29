/datum/random_event/major/antag/surplusops
	name = "Surplus ops"
	customization_available = 0
	required_elapsed_round_time = 40 MINUTES
	weight = 88
	disabled = 1

	required_elapsed_round_time = 5 MINUTES
	var/ghost_confirmation_delay = 1 MINUTES

	event_effect(var/source)
		..()

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as surplus operative? You may be randomly selected from the list of candidates.")
		text_messages.Add("You are eligible to be respawned as a surplus operative. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. Please wait for the game to choose, good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)

		if (!candidates)
			return
		var/datum/mind/lucky_dude = pick(candidates)

		var/mob/M3
		if (!M3)
			M3 = lucky_dude.current
		else
			return

		if (lucky_dude.special_role)
			if (lucky_dude in ticker.mode.traitors)
				ticker.mode.traitors.Remove(lucky_dude)
			if (lucky_dude in ticker.mode.Agimmicks)
				ticker.mode.Agimmicks.Remove(lucky_dude)
			if (!lucky_dude.former_antagonist_roles.Find(lucky_dude.special_role))
				lucky_dude.former_antagonist_roles.Add(lucky_dude.special_role)
			if (!(lucky_dude in ticker.mode.former_antagonists))
				ticker.mode.former_antagonists.Add(lucky_dude)

		var/mob/living/carbon/human/R = M3.humanize()
		if (R && istype(R))
			M3 = R
			R.unequip_all(1)
			equip_shitty_syndicate(R, 1)

			//objective_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
			R.set_loc(pick_landmark(LANDMARK_SYNDICATESURPLUS))
			SPAWN(0)
				R.choose_name(3, "Surplus Operative")

				lucky_dude.special_role = ROLE_NUKEOP
		else
			return
