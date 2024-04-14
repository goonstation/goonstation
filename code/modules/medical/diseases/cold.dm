/datum/ailment/disease/cold
	name = "The Cold"
	max_stages = 3
	spread = "Airborne"
	virulence = 30 // Reduced from 100 %. Station-wide, basically incurable and unavoidable epidemics weren't fun (Convair880).
	resistance_prob = 25 // Increased from 0 %.
	cure_flags = CURE_SLEEP
	associated_reagent = "mucus"
	affected_species = list("Human")
//
/datum/ailment/disease/cold/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(0.1))
				D.state = "Remissive"
				return
			if(probmult(5))
				affected_mob.emote("sneeze")
			if(probmult(5))
				affected_mob.emote("cough")
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your throat feels sore."))
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Mucous runs down the back of your throat."))
		if(3)
			if(affected_mob.sleeping && probmult(25))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.cure_disease(D)
				return
			if(probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.cure_disease(D)
			if(probmult(5))
				affected_mob.emote("sneeze")
			if(probmult(5))
				affected_mob.emote("cough")
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your throat feels sore."))
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Mucous runs down the back of your throat."))
			if(probmult(0.5))
				boutput(affected_mob, SPAN_ALERT("Your cold feels even worse, somehow."))
				affected_mob.contract_disease(/datum/ailment/disease/flu)
