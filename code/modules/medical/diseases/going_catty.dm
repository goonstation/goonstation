/datum/ailment/disease/going_catty
	name = "Toxoplasmosis"
	max_stages = 4
	spread = "Non-Contagious"
	cure_flags = CURE_ANTIBIOTICS
	associated_reagent = "mewtini"
	affected_species = list("Human")

/datum/ailment/disease/going_catty/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if(!ishuman(affected_mob))
		affected_mob.cure_disease(D)
		return
	switch(D.stage)
		if(2)
			if(probmult(5))
				affected_mob.emote("yawn")
		if(3)
			if(probmult(6))
				boutput(affected_mob, SPAN_ALERT("You feel like your ears itch."))
			if(probmult(3))
				affected_mob.emote("stretch")
			if(probmult(2))
				boutput(affected_mob, SPAN_ALERT("You feel your tailbone bending."))
			if(probmult(2))
				boutput(affected_mob, SPAN_ALERT("You feel your body contort... And like you could use some milk."))
		if(4)
			boutput(affected_mob, SPAN_ALERT("You feel your physical form condensing into something hairy and small... Uh oh..."))
			affected_mob.visible_message(SPAN_ALERT("<b>[affected_mob] transforms!</b>"))
			affected_mob.unequip_all()
			logTheThing(LOG_COMBAT, affected_mob, "is transformed into a critter cat by the [name] reagent at [log_loc(affected_mob)].")
			affected_mob.make_critter(/mob/living/critter/small_animal/cat)
