/datum/ailment/disease/royaler_bee_fever
	name = "Royaler Bee Fever"
	max_stages = 5 //bigger bee, more stages
	spread = "Non-Contagious"
	cure = "Garlic"
	associated_reagent = "royaler_be_bee"
	reagentcure = list("juice_garlic") //bees don't like garlic, apparently
	affected_species = list("Human")

/datum/ailment/disease/royaler_bee_fever/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	switch(D.stage)
		if(1)
			if(prob(5))
				affected_mob.say("Buzz")
		if(2)
			if(prob(6))
				affected_mob.say("Buzz buzz?")
			if(prob(3))
				affected_mob.say("Bzzzzzz")
		if(3)
			if(prob(4))
				boutput(affected_mob, "<span class='alert'>You hear buzzing in your head.</span>")
			if(prob(2))
				boutput(affected_mob, "<span class='alert'>You feel your body contort and expand.</span>")
		if(4)
			if(prob(5))
				boutput(affected_mob, "<span class='alert'>The buzzing in your head grows loud.</span>")
		if(5)
			boutput(affected_mob, "<span class='alert'>You feel your physical form condensing into something large, floating, and yellow... What?</span>")
			affected_mob.visible_message("<span class='alert'><b>[affected_mob] transforms!</b></span>")
			affected_mob.unequip_all()
			affected_mob.make_critter(/mob/living/critter/small_animal/bee/queen/big, affected_mob)
