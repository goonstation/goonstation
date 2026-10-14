/datum/ailment/disease/dehydration // applied to frogs on 25 thirst or below
	name = "Dehydration"
	scantype = "Medical Emergency"
	max_stages = 2
	stage_prob = 0 // stage progression is contingent on thirst values, not RNG
	spread = null // dehydration is not contagious, contrary to popular belief
	cure_flags = CURE_CUSTOM
	cure_desc = "Water ingestion"
	affected_species = list("Human")
//
/datum/ailment/disease/dehydration/stage_act(var/mob/living/carbon/human/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!affected_mob.sims?.getValue("Thirst"))
		affected_mob.cure_disease(D) // if you don't have thirst you can't get dehydrated
		return

	if (affected_mob.sims.getValue("Thirst") > 25.0)
		affected_mob.cure_disease(D)
		return

	switch(D.stage)
		if(1)
			if(probmult(10))
				affected_mob.visible_message(SPAN_EMOTE(pick("[affected_mob] wrinkles up conspicuously.", "[affected_mob] quietly wheezes.", "[affected_mob]'s third eyelids stick to [his_or_her(affected_mob)] eyes for a moment.")))
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your throat feels dry."))
			if (affected_mob.sims.getValue("Thirst") < 1.0)
				D.stage = 2
		if(2)
			if (probmult(50))
				affected_mob.take_oxygen_deprivation(15)
			if(probmult(20))
				affected_mob.emote(pick("choke","gasp"))
			if(probmult(10))
				affected_mob.visible_message(SPAN_ALERT(pick("[affected_mob] struggles to breathe!", "[affected_mob] gasps for air!")))
			if (affected_mob.sims.getValue("Thirst") > 1.0)
				D.stage = 1
