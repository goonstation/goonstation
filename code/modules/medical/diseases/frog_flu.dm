/datum/ailment/disease/frog_flu
	name = "Frog Flu"
	max_stages = 4
	spread = "Non-Contagious"
	cure = "Robustissin, Robust Coffee, getting robusted"
	associated_reagent = "sheltestgrog"
	reagentcure = list("robustissin", "coffee")
	affected_species = list("Human")
	stage_prob = 15

/datum/ailment/disease/frog_flu/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	if(affected_mob.health <= 15 && prob(33))
		boutput(affected_mob, "<span class='alert'>You feel the frog essence leaving your battered body.</span>")
		affected_mob.cure_disease(D)
		return
	switch(D.stage)
		if(2)
			if(prob(5))
				affected_mob.say("croak")
		if(3)
			if(prob(6))
				affected_mob.say("croak")
			if(prob(3))
				affected_mob.say("ribbit")
			if(prob(2))
				boutput(affected_mob, "<span class='alert'>You start turning green.</span>")
			if(prob(2))
				boutput(affected_mob, "<span class='alert'>You feel your body contort.</span>")
		if(4)
			boutput(affected_mob, "<span class='alert'>You feel your physical form condensing into something small and green... What?</span>")
			affected_mob.visible_message("<span class='alert'><b>[affected_mob] transforms!</b></span>")
			affected_mob.unequip_all()
			affected_mob.make_critter(/mob/living/critter/small_animal/frog, affected_mob)
