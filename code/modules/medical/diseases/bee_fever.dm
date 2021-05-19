/datum/ailment/disease/bee_fever
	name = "Bee Fever"
	max_stages = 4
	spread = "Non-Contagious"
	cure = "Garlic"
	associated_reagent = "be_bee"
	reagentcure = list("juice_garlic") //bees don't like garlic, apparently
	affected_species = list("Human")

/datum/ailment/disease/bee_fever/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(prob(5))
				affected_mob.say("buzz")
		if(3)
			if(prob(6))
				affected_mob.say("buzz buzz?")
			if(prob(3))
				affected_mob.say("bzzzzzz")
			if(prob(2))
				boutput(affected_mob, "<span class='alert'>You feel your body contort.</span>")
		if(4)
			boutput(affected_mob, "<span class='alert'>You feel your physical form condensing into something floating and yellow... What?</span>")
			affected_mob.visible_message("<span class='alert'><b>[affected_mob] transforms!</b></span>")
			affected_mob.unequip_all()
			affected_mob.make_critter(/mob/living/critter/small_animal/bee, affected_mob)
