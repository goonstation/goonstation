/datum/ailment/disease/dehydration // applied to frogs on 25 thirst or below
	name = "Dehydration"
	scantype = "Medical Emergency"
	max_stages = 2
	stage_prob = 0 // stage progression is contingent on thirst values, not RNG
	spread = "The patient is lethally dehydrated"
	cure_flags = CURE_CUSTOM
	cure_desc = "Water ingestion"
	affected_species = list("Human")
//
/datum/ailment/disease/dehydration/stage_act(var/mob/living/carbon/human/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!isfrog(affected_mob))
		affected_mob.cure_disease(D) // frogs only, bucko (otherwise it could cause issues with the thirst sim on classic)
		return

	if (affected_mob.sims.getValue("Thirst") > 25.0)
		affected_mob.cure_disease(D)
		return

	switch(D.stage)
		if(1)
			if(probmult(3))
				affected_mob.visible_message(SPAN_EMOTE("[affected_mob] wrinkles up conspicuously."))
			if(probmult(3))
				affected_mob.visible_message(SPAN_EMOTE("[affected_mob] quietly wheezes."))
			if(probmult(5))
				affected_mob.visible_message(SPAN_EMOTE("[affected_mob]'s third eyelids stick to [his_or_her(affected_mob)] eyes for a moment.")) // if dehydration is ever used on nonfrogs, adding if (isfrog(affected_mob)) for this one is a good idea i think
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your throat feels dry."))
			if (affected_mob.sims.getValue("Thirst") < 1.0)
				D.stage = 2
		if(2)
			if (probmult(50)) // probably not the value we want for this
				affected_mob.take_oxygen_deprivation(15)
			if(probmult(10))
				affected_mob.emote("choke")
			if(probmult(10))
				affected_mob.emote("gasp")
			if(probmult(5))
				affected_mob.visible_message(SPAN_ALERT("[affected_mob] struggles to breathe!"))
			if(probmult(5))
				affected_mob.visible_message(SPAN_ALERT("[affected_mob] gasps for air!"))
			if (affected_mob.sims.getValue("Thirst") > 1.0)
				D.stage = 1
