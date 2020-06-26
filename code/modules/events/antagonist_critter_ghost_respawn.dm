//very similar to playable_pests.dm :)
/datum/random_event/major/antag/antagonist_pest
	name = "Antagonist Critter Spawn"
	customization_available = 1
	var/num_critters = 0
	var/critter_type = null
#ifdef RP_MODE
	disabled = 1
#endif

	required_elapsed_round_time = 5 MINUTES

	var/ghost_confirmation_delay = 1 MINUTES // time to acknowledge or deny respawn offer.
	var/list/pest_invasion_critter_types = list(\
	list(/mob/living/critter/spider/baby),\
	list(/mob/living/critter/fire_elemental),\
	list(/mob/living/critter/gunbot),)


	admin_call(var/source)
		if (..())
			return

		switch (alert(usr, "Choose the critter type?", src.name, "Random", "Custom"))
			if ("Custom")
				src.critter_type = input("Enter a /mob/living/critter path or partial name", src.name, null) as null|text
				src.critter_type = get_one_match(src.critter_type, "/mob/living/critter")
				if (!src.critter_type)//invalid entry
					return
			if ("Random") //random
				src.critter_type = null

		src.num_critters = input(usr, "How many critter antagonists to spawn?", src.name, 0) as num|null
		if (!src.num_critters || src.num_critters < 1)
			cleanup_event()
			return
		else
			src.num_critters = round(src.num_critters)

		//confirmation
		if (alert(usr, "You have chosen to spawn [src.num_critters] [src.critter_type ? src.critter_type : "random critters"]. Is this correct?", src.name, "Yes", "No") == "Yes")
			event_effect(source)
		else
			cleanup_event()

	event_effect(var/source)
		..()

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a random antagonist critter? You may be randomly selected from the list of candidates.")
		text_messages.Add("You are eligible to be respawned as a random antagonist critter. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. Please wait for the game to choose, good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)


		if (candidates.len)
			var/list/EV = list()
			for(var/obj/landmark/S in landmarks)
				if (S.name == "peststart")
					EV.Add(S.loc)
				LAGCHECK(LAG_HIGH)

			EV += (clownstart + monkeystart + blobstart + kudzustart)

			if(!EV.len)
				EV += latejoin
				if (!EV.len)
					message_admins("Pests event couldn't find a pest landmark!")
					cleanup_event()
					return

			var/atom/pestlandmark = pick(EV)

			var/list/select = null
			if (src.critter_type)
				select = src.critter_type
			else
				select = pick(src.pest_invasion_critter_types)

			if (src.num_critters) //custom selected
				src.num_critters = (min(src.num_critters, candidates.len))
			else //random selected
				src.num_critters = rand(1,min(3,candidates.len))

			for (var/i in 1 to src.num_critters)
				if (!candidates || !candidates.len)
					break

				var/datum/mind/M = pick(candidates)
				if (M.current)
					M.current.make_critter(pick(select), pestlandmark)
					bad_traitorify(M.current)
				candidates -= M

			command_alert("Our sensors have detected a hostile nonhuman lifeform in the vicinity of the station.", "Hostile Critter")
		cleanup_event()

	proc/cleanup_event()
		src.critter_type = null
		src.num_critters = 0
