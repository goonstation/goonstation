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
		//set up objectives
		var/objectiveslist = list(
		/datum/objective/regular/steal,
		/datum/objective/regular/steal,
		/datum/objective/regular/steal/authdisc,
		/datum/objective/regular/assassinate,
		/datum/objective/regular/assassinate,
		/datum/objective/regular/assassinate,
		/datum/objective/regular/bonsaitree
		)

		var/list/chosenobjectives = null//to ensure all of them have the same objectives, pick them prematurely
		var/tempobjective = pick(objectiveslist)
		chosenobjectives += tempobjective
		//chosenobjectives +=	pick(objectiveslist)
		//chosenobjectives +=	pick(objectiveslist)
		//objectives are actually assigned further down in the respawn code

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
			message_admins("There are less than three potential candidates for surplus ops, this will cause issues!") //once build is final, it won't ever trigger if theres less than 3 dead folks
		for (var/i in 1 to 3)
			var/datum/mind/lucky_dude = pick(candidates)

			if (lucky_dude.special_role) //purge roles
				if (lucky_dude in ticker.mode.traitors)
					ticker.mode.traitors.Remove(lucky_dude)
				if (lucky_dude in ticker.mode.Agimmicks)
					ticker.mode.Agimmicks.Remove(lucky_dude)
				if (!lucky_dude.former_antagonist_roles.Find(lucky_dude.special_role))
					lucky_dude.former_antagonist_roles.Add(lucky_dude.special_role)
				if (!(lucky_dude in ticker.mode.former_antagonists))
					ticker.mode.former_antagonists.Add(lucky_dude)
			//the following code is functional, but genuinely awful
			var/mob/M3 //create a mob, assign it to our winner
			if (!M3)
				M3 = lucky_dude.current
			else
				return

			var/mob/living/carbon/human/R = M3.humanize()//since humanize is local to the mob proc, we then have to turn the generic mob into a human

			if (R && istype(R))
				M3 = R
				R.unequip_all(1)

				//now that we have a human, put them at the spawnpoints and set them up
				R.set_loc(pick_landmark(LANDMARK_SYNDICATESURPLUS))
				SPAWN(0)
					equip_shitty_syndicate(R, 1)//do this after the name call to prevent their agent cards from changing
					R.choose_name(3, "Surplus Operative")
					lucky_dude.special_role = ROLE_NUKEOP //not ideal, but functional and efficient
					R.antagonist_overlay_refresh(1, 0)
					boutput(R, "<span class='notice'>You are a surplus operative!</span>")
					ticker.mode.bestow_objective(R, tempobjective)
					for (var/datum/objective/Obj in lucky_dude.objectives)
						boutput(R, "<b>Objective #[i]</b>: [Obj.explanation_text]")
						lucky_dude.store_memory(Obj.explanation_text)

			candidates -= lucky_dude //start the whole process over again for the other two
