/datum/ailment/disease/kuru
	name = "Space Kuru"
	max_stages = 4
	cure_flags = CURE_INCURABLE
	associated_reagent = "prions"
	affected_species = list("Human")

/datum/ailment/disease/kuru/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/D)
	var/mob/living/carbon/human/H = affected_mob
	if(istype(H) && istype(H.mutantrace, /datum/mutantrace/ithillid))
		D.state = "Asymptomatic"

/datum/ailment/disease/kuru/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(1)
			if (prob(50))
				affected_mob.emote("laugh")
			else
				affected_mob.make_jittery(25 * mult)
		if(2)
			if (probmult(50))
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(SPAN_ALERT("<B>[affected_mob]</B> laughs uncontrollably!"), 1)
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.changeStatus("knockdown", 10 SECONDS)
				affected_mob.make_jittery(250)
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
		if(3)
			if(probmult(25))
				boutput(affected_mob, SPAN_ALERT("You feel like you are about to drop dead!"))
				boutput(affected_mob, SPAN_ALERT("Your body convulses painfully!"))
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				random_brute_damage(affected_mob, 5)
				affected_mob.take_oxygen_deprivation(5)
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.changeStatus("knockdown", 10 SECONDS)
				affected_mob.make_jittery(250)
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(SPAN_ALERT("<B>[affected_mob]</B> laughs uncontrollably!"), 1)
		if(4)
			if(probmult(25))
				boutput(affected_mob, SPAN_ALERT("You feel like you are going to die!"))
				affected_mob.take_oxygen_deprivation(75)
				random_brute_damage(affected_mob, 75)
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.changeStatus("knockdown", 10 SECONDS)
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(SPAN_ALERT("<B>[affected_mob]</B> laughs uncontrollably!"), 1)










