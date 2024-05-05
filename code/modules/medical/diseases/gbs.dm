/datum/ailment/disease/gbs
	name = "GBS"
	max_stages = 5
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Cryoxadone"
	reagentcure = list("cryoxadone")
	recureprob = 10
	associated_reagent = "gibbis"
	affected_species = list("Human")


/datum/ailment/disease/gbs/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(45))
				affected_mob.take_toxin_damage(5)
			if(probmult(1))
				affected_mob.emote("sneeze")
		if(3)
			if(probmult(5))
				affected_mob.emote("cough")
			else if(probmult(5))
				affected_mob.emote("gasp")
			if(probmult(10))
				boutput(affected_mob, SPAN_ALERT("You're starting to feel very weak..."))
		if(4)
			if(probmult(10))
				affected_mob.emote("cough")
			affected_mob.take_toxin_damage(5 * mult)
		if(5)
			boutput(affected_mob, SPAN_ALERT("Your body feels as if it's trying to rip itself open..."))
			if(probmult(50))
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(SPAN_ALERT("<B>[affected_mob]</B> starts convulsing violently!"), 1)
				affected_mob.changeStatus("knockdown", 15 SECONDS)
				affected_mob.make_jittery(1000)
				SPAWN(rand(20, 100))
					if (affected_mob)
						logTheThing(LOG_COMBAT, affected_mob, "was gibbed by the disease [name] at [log_loc(affected_mob)].")
						affected_mob.gib()
				return
		else
			return
