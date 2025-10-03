/obj/machinery/artifact/mindscrambler
	name = "mindscrambler"
	associated_datum = /datum/artifact/mindscrambler

	attackby(obj/item/W, mob/user)
		/datum/artifact/mindscrambler/attacked_artifact = src.associated_datum
		if (istype(W, /obj/item/bible))
			attacked_artifact.exorcised = attacked_artifact.exorcised + 1
			switch (attacked_artifact.exorcised)
				if(1)
					//Knock back
				if(2)
					//Hiss and knock back
				if(3)
					attacked_artifact.ArtifactDeactivated()


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
