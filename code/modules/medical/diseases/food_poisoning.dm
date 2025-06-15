/datum/ailment/disease/food_poisoning
	name = "Food Poisoning"
	max_stages = 3
	spread = "Non-Contagious"
	cure_flags = (CURE_SLEEP | CURE_ANTIBIOTICS)
	associated_reagent = "salmonella"
	affected_species = list("Human")
//
/datum/ailment/disease/food_poisoning/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(1)
			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("Your stomach feels weird."))
			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel queasy."))
				affected_mob.nauseate(1)
		if(2)
			if(affected_mob.sleeping && probmult(40))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.ailments -= src
				return
			if(probmult(1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.ailments -= src
				return
			if(probmult(10))
				affected_mob.emote("groan")
			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("Your stomach aches."))
				affected_mob.nauseate(1)
			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel nauseous."))
				affected_mob.nauseate(1)
		if(3)
			if(affected_mob.sleeping && probmult(25))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.ailments -= src
				return
			if(prob(1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.ailments -= src
			if(probmult(10))
				affected_mob.emote("moan")
			if(probmult(10))
				affected_mob.emote("groan")
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your stomach hurts."))
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("You feel sick."))
			if(probmult(20))
				affected_mob.nauseate(1)
