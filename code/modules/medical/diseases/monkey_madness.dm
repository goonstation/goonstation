/datum/ailment/disease/monkey_madness
	name = "Monkey Madness"
	max_stages = 5
	scantype = "Simian Flu"
	cure_flags = CURE_CUSTOM
	cure_desc = "Potassium"
	reagentcure = list("potassium")
	recureprob = 4 //easy to get chem
	associated_reagent = "banana peel"
	affected_species = list("Human")
	spread = "Non-Contagious"

/datum/ailment/disease/monkey_madness/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)

	if (..())
		return

	if (!ishuman(affected_mob) || ismonkey(affected_mob)) //become monkie or be destroyed
		affected_mob.cure_disease(D)
		return

	switch(D.stage)
		if(2)
			if (probmult(8))
				boutput(affected_mob, SPAN_ALERT("You have a sudden craving for bananas."))
			if (probmult(9))
				boutput(affected_mob, SPAN_ALERT("Your mind fills with visions of the jungle."))
			if (probmult(5))
				affected_mob.emote("panic")
				affected_mob.make_jittery(10 SECONDS)
		if(3)
			if (probmult(8))
				affected_mob.say(pick("banana", "want banana"))
				affected_mob.make_jittery(10 SECONDS)
			if (probmult(9))
				boutput(affected_mob, SPAN_ALERT("You feel a crushing pain in your chest!"))
				affected_mob.emote("scream")
				random_brute_damage(affected_mob, 5)
			if (probmult(10))
				playsound(affected_mob.loc, 'sound/voice/screams/monkey_scream.ogg', 45, 1)
				affected_mob.show_message(SPAN_ALERT("[affected_mob] screams like a monkey!"), 1)
			if (probmult(4))
				boutput(affected_mob, SPAN_ALERT("Your vision goes dark!"))
				affected_mob.changeStatus("unconscious", 4 SECONDS)
		if(4)
			if (probmult(1))
				affected_mob.say("Give orange me give eat orange me eat orange give me eat orange give me you")
			if (probmult(10))
				boutput(affected_mob, SPAN_ALERT("You feel a terrible pain in your chest!"))
				affected_mob.emote("scream")
				random_brute_damage(affected_mob, 8)
			if (probmult(15))
				playsound(affected_mob.loc, 'sound/voice/screams/monkey_scream.ogg', 55, 1)
				affected_mob.show_message(SPAN_ALERT("[affected_mob] screams like a monkey!"), 1)
				affected_mob.make_jittery(10 SECONDS)
			if (probmult(20))
				affected_mob.say(pick("OOK OOK", "me want banana!", "give banana NOW!"))
		if(5)
			boutput(affected_mob, SPAN_ALERT("Your chest feels like it's about to explode!"))
			if (probmult(40))
				var/turf/T = get_turf(affected_mob)

				if(prob(20)) // rare chance to gib into gorilla
					new /mob/living/critter/gorilla/aggressive (T)
					affected_mob.implode()
					qdel(affected_mob)
					logTheThing(LOG_COMBAT, affected_mob, "was gibbed into a gorilla by the disease [name] at [log_loc(affected_mob)].")

				else // else just an angry monkie
					new /mob/living/carbon/human/npc/monkey/angry (T)
					affected_mob.implode()
					qdel(affected_mob)
					logTheThing(LOG_COMBAT, affected_mob, "was gibbed into a monkey by the disease [name] at [log_loc(affected_mob)].")



/datum/ailment/disease/monkey_madness/infectious
	spread = "Airborne" // for evil admin crimes
	associated_reagent = "infectious banana peel"

