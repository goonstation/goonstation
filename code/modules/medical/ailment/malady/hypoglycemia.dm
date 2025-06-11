/datum/ailment/malady/hypoglycemia
	name = "Hypoglycemia"
	scantype = "Medical Emergency"
	max_stages = 3
	info = "The patient has low blood sugar."
	cure_flags = CURE_CUSTOM
	cure_desc = "Deactivation of implants/augments combined with eating or glucose treatment"
	affected_species = list("Human")
	stage_advance_prob = 1

/datum/ailment/malady/hypoglycemia/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
	if(..())
		return
	if(affected_mob.nutrition > 0)
		boutput(affected_mob, SPAN_NOTICE("You feel a lot better!"))
		affected_mob.cure_disease(D)
		return
	switch(D.stage)
		if (1)
			if (probmult(4))
				boutput(affected_mob, SPAN_ALERT("You feel hungry!"))
			if (probmult(2))
				boutput(affected_mob, SPAN_ALERT("You have a headache!"))
			if (probmult(2))
				boutput(affected_mob, SPAN_ALERT("You feel [pick("anxious","depressed")]!"))
		if(2)
			if (probmult(4))
				boutput(affected_mob, SPAN_ALERT("You feel like everything is wrong with your life!"))
			if (probmult(5))
				affected_mob.changeStatus("slowed", rand(8,32) SECONDS)
				boutput(affected_mob, SPAN_ALERT("You feel [pick("tired", "exhausted", "sluggish")]."))
			if (probmult(5))
				affected_mob.changeStatus("knockdown", 12 SECONDS)
				affected_mob.stuttering = max(10, affected_mob.stuttering)
				boutput(affected_mob, SPAN_ALERT("You feel [pick("numb", "confused", "dizzy", "lightheaded")]."))
				affected_mob.emote("collapse")
		if(3)
			if(probmult(8))
				affected_mob.contract_disease(/datum/ailment/malady/shock,null,null,1)
			if(probmult(12))
				affected_mob.changeStatus("knockdown", 12 SECONDS)
				affected_mob.stuttering = max(10, affected_mob.stuttering)
				boutput(affected_mob, SPAN_ALERT("You feel [pick("numb", "confused", "dizzy", "lightheaded")]."))
				affected_mob.emote("collapse")
			if (probmult(12))
				boutput(affected_mob, SPAN_ALERT("You feel [pick("tired", "exhausted", "sluggish")]."))
				affected_mob.changeStatus("slowed", rand(8,32) SECONDS)
