/datum/ailment/malady/shock
	name = "Shock"
	scantype = "Medical Emergency"
	info = "The patient is in shock."
	max_stages = 3
	cure_flags = CURE_CUSTOM
	cure_desc = "Saline solution"
	reagentcure = list("saline"=10)
	affected_species = list("Human","Monkey")
	stage_advance_prob = 6
	advance_time_minimum = 20 SECONDS

/datum/ailment/malady/shock/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
	if (..())
		return
	if (affected_mob.health >= 25 && affected_mob.nutrition >= 0)
		var/mob/living/carbon/human/H = null
		if(ishuman(affected_mob))
			H = affected_mob
		if(!H || H.blood_volume > 250)
			boutput(affected_mob, SPAN_NOTICE("You feel better."))
			affected_mob.cure_disease(D)
			return
	switch(D.stage)
		if (1)
			if (probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.cure_disease(D)
				return
			if (probmult(8))
				affected_mob.emote(pick("shiver", "pale", "moan"))
			if (probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel weak!"))
		if (2)
			if (probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.cure_disease(D)
				return
			if (probmult(8))
				affected_mob.emote(pick("shiver", "pale", "moan", "shudder", "tremble"))
			if (probmult(5))
				affected_mob.emote("faint", "collapse", "groan")
			if (probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel absolutely terrible!"))
		if (3)
			if (probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.cure_disease(D)
				return
			if (probmult(8))
				affected_mob.emote(pick("shudder", "pale", "tremble", "groan", "shake"))
			if (probmult(5))
				affected_mob.emote(pick("faint", "collapse", "groan"))
			if (probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel horrible!"))
			if (probmult(7))
				boutput(affected_mob, SPAN_ALERT("You can't breathe!"))
				affected_mob.losebreath++
			if (probmult(5))
				affected_mob.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
