/obj/machinery/artifact/mindscrambler
	name = "mindscrambler"
	associated_datum = /datum/artifact/mindscrambler

	Artifact_attackby(obj/item/W, mob/user)
		. = ..()
		var/datum/artifact/mindscrambler/artifact = src.artifact
		if(artifact.activated == FALSE)
			return
		if (istype(W, /obj/item/bible))
			artifact.exorcised = artifact.exorcised + 1
			playsound(src.loc, 'sound/effects/faithbiblewhack.ogg', 50, 1, -1)
			for (var/mob/living/carbon/human/remembered_body in artifact.remembered_bodies)
				remembered_body.emote("scream")
				remembered_body.changeStatus("unconscious", 1 SECONDS)
				remembered_body.force_laydown_standup()
			switch (artifact.exorcised)
				if(1)
					//Knock back
				if(2)
					//Hiss and knock back
				if(3)
					playsound(src.loc, 'sound/voice/wraith/revleave.ogg', 50, 1, -1)
					src.ArtifactDeactivated()
		else if (istype(W, /obj/item/implant/mindhack))
			//TODO: Add mindhack attunement.


/datum/artifact/mindscrambler
	associated_object = /obj/machinery/artifact/mindscrambler
	type_name = "mindscrambler"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 50 //Powerful effect, thus rare.
	validtypes = list("martian" ,"precursor" ,"wizard" ,"eldritch", "ancient")
	validtriggers = list(/datum/artifact_trigger/carbon_touch)
	//validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/language)
	activ_text = "extends several antennas!"
	deact_text = "retracts its antennas."
	react_xray = list(15,75,90,3,"ANTENNAS")
	var/can_previous_targets_scramble_again = TRUE
	var/list/remembered_bodies = new/list()
	var/mob/living/carbon/human/last_activating_body
	var/list/original_minds = new/list()
	var/list/original_bodies = new/list()
	var/mindscramble_cooldown = 30 SECONDS
	var/list/cooldowns = new/list()
	var/exorcised = 0

	post_setup()
		..()

	effect_touch(obj/O, mob/living/user)
		. = ..()
		var/turf/T = get_turf(O)
		//Various rejection criteria.
		if(GET_COOLDOWN(src, "mind_scramble"))
			T.visible_message("<b>[O]</b>'s antennas remain inactive.")
			return
		if(!isalive(user) || !ishuman(user))
			T.visible_message("<b>[O]</b>'s antennas remain inactive.")
			return
		var/mob/living/carbon/human/H = user
		if(!H.mind)
			T.visible_message("<b>[O]</b>'s antennas remain inactive.")
			return
		if(H in src.remembered_bodies)
			T.visible_message("<b>[O]</b>'s antennas blink.")
			boutput(user, SPAN_ALERT("[O] rejects your soul. It already remembers you."))
			return
		if(H == src.last_activating_body)
			T.visible_message("<b>[O]</b>'s antennas blink.")
			boutput(user, SPAN_ALERT("[O] rejects your soul. It already remembers you from last time."))
			return

		//Clear out non-legal targets.
		var/list/remembered_bodies_holder = src.remembered_bodies
		for (var/mob/living/carbon/human/remembered_body in remembered_bodies_holder)
			if(!remembered_body.mind)
				src.remembered_bodies.Remove(remembered_body)
				continue
			if(!isalive(remembered_body))
				src.remembered_bodies.Remove(remembered_body)
				continue

		//Add the toucher
		src.remembered_bodies.Add(H)
		src.last_activating_body = H
		src.original_minds.Add(H.mind)
		src.original_bodies.Add(H)
		T.visible_message("<b>[O]</b>'s antennas glow!")
		boutput(H, SPAN_ALERT("[O] peers into your mind!"))

		//We don't scramble if there's only 1 body.
		if(length(src.remembered_bodies) == 1)
			return

		//SCRAMBLE TIME!
		T.visible_message("<b>[O]</b>'s antennas flash!")
		//Sattolo's algorithm. Randomizes the list ensuring nobody keeps the same position as before.
		var/list/new_bodies = new/list()
		for (var/i in src.remembered_bodies)
			new_bodies.Add(i)
		var/position_one = length(src.remembered_bodies)
		var/position_two
		while (position_one > 1)
			position_one = position_one - 1
			position_two = rand(0, position_one - 1)
			new_bodies.Swap(position_one+1, position_two+1)

		//Cool animation
		for (var/mob/living/carbon/human/remembered_body in src.remembered_bodies)
			playsound(remembered_body.loc, 'sound/effects/ghost.ogg', 50, 1, -1) //Could be overwhelming if a lot of them are close by each other.
			animate_levitate(remembered_body, -1, 10)
		for (var/i = 0, i < 30, i++)
			var/delay = 5
			switch(i)
				if (21 to INFINITY)
					delay = 0.25
				if (15 to 21)
					delay = 0.5
				if (12 to 15)
					delay = 1
				if (4 to 12)
					delay = 2
				if (0 to 4)
					delay = 3
			for (var/mob/living/carbon/human/remembered_body in src.remembered_bodies)
				remembered_body.set_dir(turn(remembered_body.dir, 90))
			sleep(delay)
		for (var/mob/living/carbon/human/remembered_body in src.remembered_bodies)
			playsound(remembered_body.loc, 'sound/effects/lightning_strike.ogg', 50, 1, -1)
			animate_stop(remembered_body)

		//Perform the swaps, ensuring nobody gets swapped multiple times.
		var/nr_of_bodies = length(new_bodies)
		for (var/i = 1 to nr_of_bodies)
			if(!(new_bodies[i] == src.remembered_bodies[i]))
				for (var/j = i + 1 to nr_of_bodies)
					if(src.remembered_bodies[j] == new_bodies[i])
						var/mob/living/carbon/human/swap_human = src.remembered_bodies[i]
						boutput(src.remembered_bodies[i], SPAN_ALERT("[O] drags you out of your body!"))
						boutput(src.remembered_bodies[j], SPAN_ALERT("[O] drags you out of your body!"))
						swap_human.mind.swap_with(src.remembered_bodies[j])
						src.remembered_bodies.Swap(i, j)
						break

		ON_COOLDOWN(src, "mind_scramble", src.mindscramble_cooldown)
		SPAWN(src.mindscramble_cooldown)
			T.visible_message("<b>[O]</b>'s antennas become active again!")

	effect_deactivate(obj/O)
		. = ..()
		//TODO Figure out and add some checks to see if we want to transfer dead minds to their old bodies.
		var/nr_of_minds = length(src.original_minds)
		for (var/i = 1 to nr_of_minds)
			var/datum/mind/original_mind = src.original_minds[i]
			var/mob/living/carbon/human/original_body = src.original_bodies[i]
			if(!(original_mind == original_body.mind))
				original_mind.swap_with(original_body)

		src.original_minds = list()
		src.original_bodies = list()
		src.remembered_bodies = list()
		src.last_activating_body = ""
		src.exorcised = 0
