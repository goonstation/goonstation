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
			switch (artifact.exorcised) //Possibly some kind of retribution from the artifact?
				if(1)
					//First hit
				if(2)
					//Second hit
				if(3)
					playsound(src.loc, 'sound/voice/wraith/revleave.ogg', 50, 1, -1)
					src.ArtifactDeactivated()
		else if (istype(W, /obj/item/implanter/mindhack))
			artifact.mindhack_attuned = TRUE
			artifact.mindhack_owner = user
			boutput(user, SPAN_ALERT("[src] absorbs and attunes to the mindhack implant."))
			qdel(W)

	examine()
		. = ..()
		var/datum/artifact/mindscrambler/artifact = src.artifact
		if(artifact.activated && istraitor(usr))
			. += SPAN_ARTHINT(" You notice there's a small opening the exact size and shape of a Mindhack implant.")
		if(artifact.activated && usr.traitHolder?.hasTrait("training_chaplain"))
			. += SPAN_ARTHINT(" This artifact is clearly diabolical!")

/datum/artifact/mindscrambler
	associated_object = /obj/machinery/artifact/mindscrambler
	type_name = "mindscrambler"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 100 //Powerful effect, thus rare.
	validtypes = list("eldritch") //Straight up evil.
	validtriggers = list(/datum/artifact_trigger/carbon_touch)
	//validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/language)
	activ_text = "extends several antennas!"
	deact_text = "retracts its antennas."
	react_xray = list(15,75,90,3,"ANTENNAS")
	var/can_previous_targets_scramble_again = TRUE
	var/list/remembered_minds = new/list()
	var/list/remembered_bodies = new/list()
	var/mob/living/carbon/human/last_activating_body
	var/list/original_minds = new/list()
	var/list/original_bodies = new/list()
	var/mindscramble_cooldown = 30 SECONDS
	var/list/cooldowns = new/list()
	var/exorcised = 0
	var/mindhack_attuned = FALSE
	var/mob/mindhack_owner

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
		if(ischangeling(user) || isvampire(user) || isarcfiend(user))
			T.visible_message("<b>[O]</b>'s antennas remain inactive.")
			boutput(user, SPAN_ALERT("[O] rejects your inhuman soul."))
			return
		var/mob/living/carbon/human/H = user
		if(!H.mind)
			T.visible_message("<b>[O]</b>'s antennas remain inactive.")
			return
		if(H == src.last_activating_body)
			T.visible_message("<b>[O]</b>'s antennas blink.")
			boutput(user, SPAN_ALERT("[O] rejects your soul. It already remembers you from last time."))
			return
		if(H in src.original_bodies)
			T.visible_message("<b>[O]</b>'s antennas blink.")
			boutput(user, SPAN_ALERT("[O] rejects your soul. It already remembers you."))
			return
		if(H.mind in src.original_minds)
			T.visible_message("<b>[O]</b>'s antennas blink.")
			boutput(user, SPAN_ALERT("[O] rejects your soul. It already remembers you."))
			return

		src.clean_remembered_bodies_and_minds()

		//Add the toucher
		src.original_minds.Add(H.mind)
		src.original_bodies.Add(H)
		src.remembered_minds.Add(H.mind)
		src.remembered_bodies.Add(H)
		src.last_activating_body = H
		T.visible_message("<b>[O]</b>'s antennas glow!")
		boutput(H, SPAN_ALERT("[O] peers into your mind!"))

		//We don't scramble if there's only 1 body.
		if(length(src.remembered_bodies) == 1)
			return

		//SCRAMBLE TIME!
		T.visible_message("<b>[O]</b>'s antennas flash!")
		var/list/new_minds_order = src.sattolos_algo(src.remembered_minds)
		src.animate_mindscramble(src.remembered_bodies)

		//Put all minds in some temporary holders to make room for the new ones.
		var/list/temporary_bodies = new/list()
		for (var/mob/living/carbon/human/remembered_body in src.remembered_bodies)
			var/mob/temp_body = new/mob(remembered_body.loc)
			remembered_body.mind.transfer_to(temp_body)
			temporary_bodies.Add(temp_body)

		//Perform the transfers
		for (var/i = 1 to length(new_minds_order))
			var/datum/mind/new_mind = new_minds_order[i]
			var/mob/living/carbon/human/remembered_body = src.remembered_bodies[i]
			new_mind.transfer_to(remembered_body)

		//Delete the temporary bodies.
		for (var/mob/temp_body in temporary_bodies)
			qdel(temp_body)

		if(src.mindhack_attuned)
			for (var/mob/living/carbon/human/remembered_body in src.remembered_bodies)
				if(remembered_body.mind)
					//Only mindhack them if they aren't already mindhacked.
					if(!remembered_body.mind.get_antagonist(ROLE_MINDHACK))
						var/mob/target = remembered_body
						target.setStatus("mindhack", null, src.mindhack_owner, null)
						//Did you just touch the artifact you just told to mindhack anyone who touches? Lol, lmao even. Now SOMEBODY is the leader.
						if(remembered_body == src.mindhack_owner)
							boutput(remembered_body, SPAN_ALERT("You feel utterly strengthened in your resolve! You are the most important person in the universe!"))
							tgui_alert(remembered_body, "You feel utterly strengthened in your resolve! You are the most important person in the universe!", "YOU ARE REALY GREAT!!")
			logTheThing(LOG_COMBAT, src.mindhack_owner, "has mindhacked people through the use of the Mindscramble artifact [O] at [log_loc(O)].")

		src.remembered_minds = new_minds_order

		ON_COOLDOWN(src, "mind_scramble", src.mindscramble_cooldown)
		SPAWN(src.mindscramble_cooldown)
			T.visible_message("<b>[O]</b>'s antennas become active again!")

	effect_deactivate(obj/O)
		. = ..()
		var/turf/T = get_turf(O)
		//First try to distribute original minds to their original bodies.
		var/list/leftover_bodies = new/list()
		var/list/minds_without_bodies = new/list()

		//Put all minds in some temporary holders to make room for the new ones.
		var/list/temporary_bodies = new/list()
		for (var/mob/living/carbon/human/remembered_body in src.remembered_bodies)
			var/mob/temp_body = new/mob(remembered_body.loc)
			remembered_body.mind.transfer_to(temp_body)
			temporary_bodies.Add(temp_body)

		//Try to distribute original minds to original bodies as far as possible.
		for (var/i = 1 to length(src.original_minds))
			var/datum/mind/original_mind = src.original_minds[i]
			var/mob/living/carbon/human/original_body = src.original_bodies[i]
			//If the body is dead, there's nothing to return to.
			if(!(original_body in src.remembered_bodies))
				minds_without_bodies.Add(original_mind)
				continue
			//If the mind died while in another body, they don't get ressureccted.
			if(!(original_mind in src.remembered_minds))
				leftover_bodies.Add(original_body)
				continue
			original_mind.transfer_to(original_body)
			boutput(original_body, SPAN_ALERT("[O] is forced to return you to your original body!"))

		//Then distribute minds without bodies to leftover bodies.
		var/list/new_minds_order = src.sattolos_algo(minds_without_bodies)
		for (var/i = 1 to length(new_minds_order))
			var/datum/mind/new_mind = new_minds_order[i]
			var/mob/living/carbon/human/remembered_body = leftover_bodies[i]
			new_mind.transfer_to(remembered_body)
			boutput(original_body, SPAN_ALERT("[O] couldn't return you to your original body.. This is who you are now."))

		//Delete the temporary bodies.
		for (var/mob/temp_body in temporary_bodies)
			qdel(temp_body)

		//And finally, take off any applied mindhacks.
		if(src.mindhack_attuned)
			for (var/mob/living/carbon/human/original_body in src.original_bodies)
				original_body.delStatus("mindhack")

		src.original_minds = list()
		src.original_bodies = list()
		src.remembered_minds = list()
		src.remembered_bodies = list()
		src.last_activating_body = ""
		src.exorcised = 0
		src.mindhack_attuned = FALSE
		src.mindhack_owner = ""

	proc/animate_mindscramble(var/list/remembered_bodies)
		//Levitate everybody, spin them around, drop em down and play the lightning strike.
		for (var/mob/living/carbon/human/remembered_body in remembered_bodies)
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
			for (var/mob/living/carbon/human/remembered_body in remembered_bodies)
				remembered_body.set_dir(turn(remembered_body.dir, 90))
			sleep(delay)
		for (var/mob/living/carbon/human/remembered_body in remembered_bodies)
			playsound(remembered_body.loc, 'sound/effects/lightning_strike.ogg', 50, 1, -1)
			animate_stop(remembered_body)

	proc/sattolos_algo(var/list/original_list)
		//Sattolo's algorithm. Randomizes the list ensuring nobody keeps the same position as before.
		var/list/shuffled_list = original_list.Copy()
		var/position_one = length(original_list)
		var/position_two
		while (position_one > 1)
			position_one = position_one - 1
			position_two = rand(0, position_one - 1)
			shuffled_list.Swap(position_one+1, position_two+1)
		return shuffled_list

	proc/make_monkey_npc(var/mob/living/carbon/human/body)
		body.is_npc = TRUE
		body.ai_aggressive = 0
		body.ai_calm_down = 1
		body.ai_default_intent = INTENT_HELP
		body.ai_init()

	proc/clean_remembered_bodies_and_minds()
		//Clear out dead bodies and the mind which occupied the body when it died. Iterate in reverse order to avoid shifting.
		var/nr_of_minds = length(src.remembered_minds)
		for (var/i = 0 to nr_of_minds - 1)
			var/i_adjusted = nr_of_minds - i
			var/datum/mind/remembered_mind = src.remembered_minds[i_adjusted]
			var/mob/living/carbon/human/remembered_body = src.remembered_bodies[i_adjusted]
			if(!isalive(remembered_body))
				src.remembered_minds.Remove(remembered_mind)
				src.remembered_bodies.Remove(remembered_body)
