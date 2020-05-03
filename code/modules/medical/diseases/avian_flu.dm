/datum/ailment/disease/avian_flu
	name = "Avian Flu"
	max_stages = 4
	spread = "Non-Contagious"
	cure = "Chicken Soup"
	associated_reagent = "feather fluid"
	reagentcure = list("chickensoup")
	affected_species = list("Human")
//
/datum/ailment/disease/avian_flu/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(prob(5))
				affected_mob.emote("flap")
		if(3)
			if(prob(6))
				affected_mob.emote("flap")
			if(prob(3))
				affected_mob.emote("aflap")
			if(prob(2))
				boutput(affected_mob, "<span class='alert'>You feel your ribcage constrict.</span>")
			if(prob(2))
				boutput(affected_mob, "<span class='alert'>You feel your body contort.</span>")
		if(4)
			boutput(affected_mob, "<span class='alert'>You feel your physical form condensing into something light and airy... What?</span>")
			affected_mob.visible_message("<span class='alert'><b>[affected_mob] transforms!</b></span>")
			affected_mob.unequip_all()
			affected_mob.make_critter(/mob/living/critter/small_animal/bird/random)
