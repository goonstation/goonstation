/datum/ailment/disease/avian_flu
	name = "Avian Flu"
	max_stages = 4
	spread = "Non-Contagious"
	cure = "Chicken Soup"
	associated_reagent = "feather fluid"
	reagentcure = list("chickensoup")
	affected_species = list("Human")
//
/datum/ailment/disease/avian_flu/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if(!ishuman(affected_mob))
		affected_mob.cure_disease(D)
		return
	switch(D.stage)
		if(2)
			if(probmult(5))
				affected_mob.emote("flap")
		if(3)
			if(probmult(6))
				affected_mob.emote("flap")
			if(probmult(3))
				affected_mob.emote("aflap")
			if(probmult(2))
				boutput(affected_mob, "<span class='alert'>You feel your ribcage constrict.</span>")
			if(probmult(2))
				boutput(affected_mob, "<span class='alert'>You feel your body contort.</span>")
		if(4)
			boutput(affected_mob, "<span class='alert'>You feel your physical form condensing into something light and airy... What?</span>")
			affected_mob.visible_message("<span class='alert'><b>[affected_mob] transforms!</b></span>")
			affected_mob.unequip_all()
			logTheThing(LOG_COMBAT, affected_mob, "is transformed into a critter bird by the [name] reagent at [log_loc(affected_mob)].")
			affected_mob.make_critter(/mob/living/critter/small_animal/bird/random)
