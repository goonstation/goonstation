/datum/ailment/disease/frog_flu
	name = "Frog Flu"
	max_stages = 4
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Robustissin, Robust Coffee, getting robusted"
	associated_reagent = "sheltestgrog"
	reagentcure = list("cold_medicine", "coffee")
	affected_species = list("Human")
	stage_prob = 5

/datum/ailment/disease/frog_flu/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if(!ishuman(affected_mob))
		affected_mob.cure_disease(D)
		return
	if(affected_mob.health <= 15 && probmult(33))
		boutput(affected_mob, SPAN_ALERT("You feel the frog essence leaving your battered body."))
		affected_mob.cure_disease(D)
		return
	switch(D.stage)
		if(2)
			if(probmult(5))
				affected_mob.say("croak")
		if(3)
			if(probmult(6))
				affected_mob.say("croak")
			if(probmult(3))
				affected_mob.say("ribbit")
			if(probmult(2))
				boutput(affected_mob, SPAN_ALERT("You start turning green."))
			if(probmult(2))
				boutput(affected_mob, SPAN_ALERT("You feel your body contort."))
		if(4)
			boutput(affected_mob, SPAN_ALERT("You feel your physical form condensing into something small and green... What?"))
			affected_mob.visible_message(SPAN_ALERT("<b>[affected_mob] transforms!</b>"))
			affected_mob.unequip_all()
			logTheThing(LOG_COMBAT, affected_mob, "is transformed into a critter frog by the [name] reagent at [log_loc(affected_mob)].")
			var/mob/living/critter/C = affected_mob.make_critter(/mob/living/critter/small_animal/frog, affected_mob)
			C.butcherable = BUTCHER_ALLOWED //So the brain is recoverable
