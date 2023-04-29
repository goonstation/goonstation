/datum/random_event/start/critters
	name = "Critter Infestation"
	customization_available = 1
	var/num_nests = 0 //number of areas
	var/num_pests = 0 //custom critter limit
	var/pest_type = null //custom critter path

	required_elapsed_round_time = 0

	var/list/invasion_critter_types = list(\
	list(/obj/critter/wasp),\
	list(/mob/living/critter/small_animal/scorpion),\
	list(/mob/living/critter/skeleton/wraith),\
	list(/mob/living/critter/spider,/mob/living/critter/spider/baby),\
	list(/mob/living/critter/spider/ice,/mob/living/critter/spider/ice/baby),\
	list(/mob/living/critter/spider/spacerachnid),\
	list(/mob/living/critter/small_animal/rattlesnake),\
	list(/mob/living/critter/fermid),)

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

		src.num_pests = input(usr, "How many pests to spawn per nest?", src.name, 0) as num|null
		if (!src.num_pests || src.num_pests < 1)
			cleanup_event()
			return
		else
			src.num_pests = round(src.num_pests)

		src.num_nests = input(usr, "How many nests to spawn?", src.name, 0) as num|null
		if (!src.num_nests || src.num_nests < 1)
			cleanup_event()
			return
		else
			src.num_nests = round(src.num_nests)

		//confirmation
		if (alert(usr, "You have chosen to spawn [src.num_pests] [src.pest_type ? src.pest_type : "random pests"] at [src.num_nests] nests. Is this correct?", src.name, "Yes", "No") == "Yes")
			event_effect(source)
		else
			cleanup_event()

	event_effect(var/source)
		..()

		var/list/EV = list()

		if (length(landmarks[LANDMARK_PESTSTART]))
			EV += landmarks[LANDMARK_PESTSTART]
		if (length(landmarks[LANDMARK_MONKEY]))
			EV += landmarks[LANDMARK_MONKEY]
		if (length(landmarks[LANDMARK_BLOBSTART]))
			EV += landmarks[LANDMARK_BLOBSTART]
		if (length(landmarks[LANDMARK_KUDZUSTART]))
			EV += landmarks[LANDMARK_KUDZUSTART]

		if(!length(EV))
			EV += landmarks[LANDMARK_LATEJOIN]
			if (!length(EV))
				message_admins("Pests event couldn't find any valid landmarks!")
				logTheThing(LOG_DEBUG, null, "Failed to find any valid landmarks for a Critter Infestation event!")
				cleanup_event()
				return

		if (!src.num_nests) //customized
			src.num_nests = rand(1,4)

		var/list/select = list()
		for(var/nest_id in 1 to src.num_nests)
			if (!length(EV))
				message_admins("Pests event couldn't find any more valid landmarks!")
				logTheThing(LOG_DEBUG, null, "Failed to find any valid more landmarks for a Critter Infestation event!")
				cleanup_event()
				return

			var/atom/pestlandmark = pick(EV)
			EV -= pestlandmark

			if(!length(select))
				if (src.pest_type) //customized
					select += src.pest_type
				else
					select += pick(src.invasion_critter_types)

			if (!src.num_pests) //customized
				src.num_pests = rand(2,10)

			for (var/i in 1 to src.num_pests)
				var/picked_critter = pick(select)
				new picked_critter(pestlandmark)

			pestlandmark.visible_message("A group of pests emerge from their hidey-hole!")

		if (src.num_pests >= 5)
			command_alert("A large number of pests have been detected onboard.", "Pest invasion", alert_origin = ALERT_STATION)
		cleanup_event()

	proc/cleanup_event()
		src.num_pests = 0
		src.num_nests = 0
		src.pest_type = null
