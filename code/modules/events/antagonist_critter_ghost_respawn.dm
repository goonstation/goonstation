//very similar to playable_pests.dm :)
/datum/random_event/major/antag/antagonist_pest
	name = "Antagonist Critter Spawn"
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

		var/input = input(usr,"Which one? Pick null for random???",src.name) as null|anything in list("fire_elemental","spider","gunbot")
		if (!input || !istext(input))
			return
		event_effect(input)


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
					return

			var/atom/pestlandmark = pick(EV)

			var/list/select = pick(pest_invasion_critter_types)
			if (source)
				if (source == "fire_elemental")
					select = list(/mob/living/critter/fire_elemental)
				if (source == "spider")
					select = list(/mob/living/critter/spider/baby)
				if (source == "gunbot")
					select = list(/mob/living/critter/gunbot)

			var/howmany = rand(1,min(3,candidates.len))
			for (var/i in 0 to howmany)
				if (!candidates || !candidates.len)
					break

				var/datum/mind/M = pick(candidates)
				if (M.current)
					M.current.make_critter(pick(select), pestlandmark)
					bad_traitorify(M.current)
				candidates -= M

			command_alert("Our sensors have detected a hostile nonhuman lifeform in the vicinity of the station.", "Hostile Critter")

