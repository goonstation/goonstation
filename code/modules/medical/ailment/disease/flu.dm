/datum/ailment/disease/flu
	name = "The Flu"
	max_stages = 3
	spread = AILMENT_SPREAD_AIRBORNE
	virulence = 30 // Reduced from 100 %. Station-wide, basically incurable and unavoidable epidemics weren't fun (Convair880).
	resistance_prob = 25 // Increased from 0 %.
	cure_flags = (CURE_SLEEP | CURE_MEDICINE | CURE_HIGH_TEMPERATURE)
	reagentcure = list("honey_tea"=3,"chickensoup"=10,"currypowder"=10,"cold_medicine"=25)
	associated_reagent = "green mucus"
	affected_species = list("Human")

/datum/ailment/disease/flu/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(1))
				affected_mob.emote("sneeze")
			if(probmult(1))
				affected_mob.emote("cough")
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your muscles ache."))
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your stomach hurts."))
				if(prob(20))
					affected_mob.take_toxin_damage(1)

		if(3)
			if(probmult(1))
				affected_mob.emote("sneeze")
			if(probmult(1))
				affected_mob.emote("cough")
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your muscles ache."))
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your stomach hurts."))
				if(prob(20))
					affected_mob.take_toxin_damage(1)
