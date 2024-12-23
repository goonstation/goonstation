/datum/ailment/disease/medusa
	name = "Petrification"
	scantype = "Disease"
	max_stages = 5
	spread = "Non-Contagious"
	reagentcure = list("omnizine")
	associated_reagent = "medusa"
	affected_species = list("Human","Monkey")
	cure_flags = CURE_CUSTOM
	cure_desc = "Omnizine"

/datum/ailment/disease/medusa/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if (probmult(8))
				boutput(affected_mob, "Your joints feel stiff.")
				random_brute_damage(affected_mob, 1)
		if(3)
			if (probmult(8))
				boutput(affected_mob, SPAN_ALERT("Your joints feel very stiff."))
				random_brute_damage(affected_mob, 2)
		if(4)
			if (probmult(10))
				boutput(affected_mob, SPAN_ALERT("You can barely move your limbs!"))
				random_brute_damage(affected_mob, 3)
		if(5)
			boutput(affected_mob, SPAN_ALERT("You can barely move!"))
			affected_mob.changeStatus("unconscious",4 SECONDS)
			if(probmult(40)) //So everyone can feel like robot Seth Brundle
				affected_mob.become_statue("rock")
