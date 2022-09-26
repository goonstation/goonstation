
/datum/random_event/major/antag/surplusops
	name = "Surplus ops"
	customization_available = 0
	required_elapsed_round_time = 40 MINUTES
	weight = 88
	disabled = 1
	var/antags_remaing_percent = 0.02 //20 percent or less

	required_elapsed_round_time = 5 MINUTES
	var/ghost_confirmation_delay = 1 MINUTES

	event_effect(var/source)
		..()

		if(get_alive_antags_percentage() >= antags_remaing_percent)
			message_admins("Surplus op deployment aborted- too many antags")
			return


		//set up objectives up here so they get the same ones (hopefully)
		var/ourobjectives = new /datum/objective_set/surplusop


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
		if(candidates.len < 3)
			message_admins("There are less than three potential candidates for surplus ops, this will cause issues with their deployment!") //once build is final, it won't ever trigger if theres less than 3 dead folks
//flockpillar says to fix:
			//take M and turn into a new human H
			//and return a ref to the new human we just made

		//spawn them in, set up as needed
		for (var/i in 1 to 3)
			var/datum/mind/chosen_mind = pick(candidates)

			if (chosen_mind.special_role) //purge roles
				if (chosen_mind in ticker.mode.traitors)
					ticker.mode.traitors.Remove(chosen_mind)
				if (chosen_mind in ticker.mode.Agimmicks)
					ticker.mode.Agimmicks.Remove(chosen_mind)
				if (!chosen_mind.former_antagonist_roles.Find(chosen_mind.special_role))
					chosen_mind.former_antagonist_roles.Add(chosen_mind.special_role)
				if (!(chosen_mind in ticker.mode.former_antagonists))
					ticker.mode.former_antagonists.Add(chosen_mind)



			//the following code is an extremely condensed version of what the midround antag event uses to respawn traitors
			//it's bad, but functional


			var/mob/M = chosen_mind.current
			var/mob/living/carbon/human/H = M.humanize()

			if (H && istype(H))
				H.unequip_all(1)

				//now that we have a human, put them at the spawnpoints and set them up
				H.set_loc(pick_landmark(LANDMARK_SYNDICATESURPLUS))
				SPAWN(0)
					equip_shitty_syndicate(H, 1)
					H.choose_name(3, "Surplus Operative")
					chosen_mind.special_role = ROLE_SURPLUS_OPERATIVE
					ticker.mode.Agimmicks |= chosen_mind  //add them to the antags

					H.antagonist_overlay_refresh(1, 0)

					boutput(H, "<span class='notice'>You are a surplus operative!</span>")
					ticker.mode.bestow_objective(H, ourobjectives)
					for (var/datum/objective/Obj in chosen_mind.objectives)
						boutput(H, "<b>Objective #[i]</b>: [Obj.explanation_text]")
						chosen_mind.store_memory(Obj.explanation_text)

			candidates -= chosen_mind //start the whole process over again for the other two
