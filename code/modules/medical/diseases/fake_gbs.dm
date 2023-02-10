/datum/ailment/disease/fake_gbs
	name = "GBS"
	max_stages = 5
	spread = "Airborne"
	cure = "Cryoxadone"
	reagentcure = list("cryoxadone")
	recureprob = 10
	associated_reagent = "stringy gibbis"
	affected_species = list("Human")

/datum/ailment/disease/fake_gbs/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(1))
				affected_mob.emote("sneeze")
		if(3)
			if(probmult(5))
				affected_mob.emote("cough")
			else if(probmult(5))
				affected_mob.emote("gasp")
			if(probmult(10))
				boutput(affected_mob, "<span class='alert'>You're starting to feel very weak...</span>")
		if(4)
			if(probmult(10))
				affected_mob.emote("cough")

		if(5)
			if(probmult(10))
				affected_mob.emote("cough")
