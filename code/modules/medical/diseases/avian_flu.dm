/datum/ailment/disease/avian_flu
	name = "Avian Flu"
	max_stages = 4
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Chicken soup"
	associated_reagent = "feather_fluid"
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
				boutput(affected_mob, SPAN_ALERT("You feel your ribcage constrict."))
			if(probmult(2))
				boutput(affected_mob, SPAN_ALERT("You feel your body contort."))
		if(4)
			boutput(affected_mob, SPAN_ALERT("You feel your physical form condensing into something light and airy... What?"))
			affected_mob.visible_message(SPAN_ALERT("<b>[affected_mob] transforms!</b>"))
			affected_mob.unequip_all()
			logTheThing(LOG_COMBAT, affected_mob, "is transformed into a critter bird by the [name] reagent at [log_loc(affected_mob)].")
			affected_mob.make_critter(/mob/living/critter/small_animal/bird/random)
