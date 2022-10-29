/datum/random_event/major/player_spawn/pests
	name = "Pests (playable)"
	customization_available = 1
	var/num_pests = 0 //custom critter limit
	var/pest_type = null //custom critter path

	required_elapsed_round_time = 5 MINUTES

	var/ghost_confirmation_delay = 1 MINUTES // time to acknowledge or deny respawn offer.
	var/list/pest_invasion_critter_types = list(\
	list(/mob/living/critter/small_animal/fly/weak, /mob/living/critter/small_animal/mosquito/weak,),\
	list(/mob/living/critter/small_animal/cat/weak,),\
	list(/mob/living/critter/small_animal/dog/pug/weak,/mob/living/critter/small_animal/dog/corgi/weak,/mob/living/critter/small_animal/dog/shiba/weak),\
	list(/mob/living/critter/changeling/eyespider,/mob/living/critter/changeling/buttcrab),\
	list(/mob/living/critter/small_animal/frog/weak),\
	list(/mob/living/critter/small_animal/cockroach/robo/weak),\
	list(/mob/living/critter/robotic/bot/cleanbot, /mob/living/critter/robotic/bot/firebot),)

	admin_call(var/source)
		if (..())
			return

		switch (alert(usr, "Choose the pest type?", src.name, "Random", "Custom"))
			if ("Custom")
				src.pest_type = input("Enter a /mob/living/critter path or partial name.", src.name, null) as null|text
				src.pest_type = get_one_match(src.pest_type, "/mob/living/critter")
				if (!src.pest_type)
					return
			if ("Random")
				src.pest_type = null

		src.num_pests = input(usr, "How many pests to spawn?", src.name, 0) as num|null
		if (!src.num_pests || src.num_pests < 1)
			cleanup_event()
			return
		else
			src.num_pests = round(src.num_pests)

		//confirmation
		if (alert(usr, "You have chosen to spawn [src.num_pests] [src.pest_type ? src.pest_type : "random pests"]. Is this correct?", src.name, "Yes", "No") == "Yes")
			event_effect(source)
		else
			cleanup_event()

	event_effect(var/source)
		..()

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a random pest? (special ghost critter)") // Don't disclose which type it is. You know, metagaming.
		text_messages.Add("You are eligible to be respawned as a random pest. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of pests. Please wait...")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 0)


		if (candidates.len)
			var/list/EV = list()

			if (length(landmarks[LANDMARK_PESTSTART]))
				EV += landmarks[LANDMARK_PESTSTART]
			if (length(landmarks[LANDMARK_MONKEY]))
				EV += landmarks[LANDMARK_MONKEY]
			if (length(landmarks[LANDMARK_BLOBSTART]))
				EV += landmarks[LANDMARK_BLOBSTART]
			if (length(landmarks[LANDMARK_KUDZUSTART]))
				EV += landmarks[LANDMARK_KUDZUSTART]
			EV += job_start_locations["Clown"]

			if(!EV.len)
				EV += landmarks[LANDMARK_LATEJOIN]
				if (!EV.len)
					message_admins("Pests event couldn't find any valid landmarks!")
					logTheThing(LOG_DEBUG, null, "Failed to find any valid landmarks for a Pests event!")
					cleanup_event()
					return

			var/atom/pestlandmark = pick(EV)
			var/list/select = list()
			if (src.pest_type) //customized
				select += src.pest_type
			else
				select += pick(src.pest_invasion_critter_types)

			if (src.num_pests) //customized
				src.num_pests = min(src.num_pests, candidates.len)
			else
				src.num_pests = length(candidates)

			for (var/i in 1 to src.num_pests)
				if (!candidates || !length(candidates))
					break

				var/datum/mind/M = pick(candidates)
				if (M.current)
					M.current.make_ghost_critter(pestlandmark,select)
					var/obj/item/implant/access/infinite/assistant/O = new /obj/item/implant/access/infinite/assistant(M.current)
					O.owner = M.current
					O.implanted = 1
				candidates -= M

			pestlandmark.visible_message("A group of pests emerge from their hidey-hole!")

			if (src.num_pests >= 5)
				command_alert("A large number of pests have been detected onboard.", "Pest invasion", alert_origin = ALERT_STATION)
		cleanup_event()

	proc/cleanup_event()
		src.num_pests = 0
		src.pest_type = null

