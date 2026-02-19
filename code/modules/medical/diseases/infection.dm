/datum/ailment/disease/infection
	name = "MRSA"
	max_stages = 3
	spread = "The patient has an aggressive Staph infection."
	cure_flags = CURE_ANTIBIOTICS
	affected_species = list("Human")
	stage_prob = 3

/datum/ailment/disease/infection/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	switch(D.stage)
		if(1)
			if(probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.resistances += src.type
				affected_mob.ailments -= src
				return
			if(prob(4)) affected_mob.emote("shiver")
		if(2)
			if(probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.resistances += src.type
				affected_mob.ailments -= src
				return
			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel feverish!"))
				affected_mob.changeBodyTemp(rand(5,10) KELVIN)
				affected_mob.take_toxin_damage(1)

			if(probmult(4)) affected_mob.emote("groan")
		if(3)
			if(probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.resistances += src.type
				affected_mob.ailments -= src
				return
			if(probmult(7))
				random_brute_damage(affected_mob, 1)
			if(probmult(7))
				affected_mob.emote(pick("tremble", "groan", "shake"))
				boutput(affected_mob, SPAN_ALERT("You feel like you're burning up!"))
				affected_mob.changeBodyTemp(rand(10,30) KELVIN)
				random_burn_damage(affected_mob,1)
				affected_mob.take_toxin_damage(1)
			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel sick!"))
				affected_mob.change_misstep_chance(5)
				affected_mob.take_toxin_damage(1)
			if(probmult(3)) affected_mob.emote(pick("faint","groan","shiver"))
