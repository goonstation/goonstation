// Addiction with comically-exaggerated withdrawal effects!

/datum/ailment/addiction
	name = "reagent addiction"
	scantype = "Chemical Dependency"
	max_stages = 5
	stage_prob = 3
	cure_flags = CURE_CUSTOM
	cure_desc = "Time"
	affected_species = list("Human")
	strain_type = /datum/ailment_data/addiction

/datum/ailment/addiction/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/addiction/D, mult)
	if (..())
		return
	if (prob(20) && (world.timeofday > (D.last_reagent_dose + D.withdrawal_duration)))
		boutput(affected_mob, SPAN_NOTICE("You no longer feel reliant on [D.associated_reagent]!"))
		affected_mob.ailments -= D
		qdel(D)
		return
	if (affected_mob.reagents && affected_mob.reagents.has_reagent(D.associated_reagent))
		D.last_reagent_dose = world.timeofday
		D.stage = 1
		return
	switch(D.stage)
		if (2)
			if (prob(8))
				affected_mob.emote("shiver")
			if (prob(8))
				affected_mob.emote("sneeze")
			if (prob(4))
				boutput(affected_mob, SPAN_NOTICE("You feel a dull headache."))
		if (3)
			if (prob(8))
				affected_mob.emote("twitch_s")
			if (prob(8))
				affected_mob.emote("shiver")
			if (prob(4))
				boutput(affected_mob, SPAN_ALERT("Your head hurts."))
			if (prob(4))
				boutput(affected_mob, SPAN_ALERT("You begin craving [D.associated_reagent]!"))
		if (4)
			if (prob(8))
				affected_mob.emote("twitch")
			if (prob(4))
				boutput(affected_mob, SPAN_ALERT("You have a pounding headache."))
			if (prob(4))
				boutput(affected_mob, SPAN_ALERT("You have the strong urge for some [D.associated_reagent]!"))
			else if (prob(4))
				boutput(affected_mob, SPAN_ALERT("You REALLY crave some [D.associated_reagent]!"))
		if (5)
			if (D.max_severity == "LOW")
				if (prob(5))
					affected_mob.changeStatus("slowed", 3 SECONDS)
					boutput(affected_mob, SPAN_ALERT("You feel [pick("tired", "exhausted", "sluggish")]."))
			else // D.max_severity is HIGH or whatever
				if (prob(5) && !affected_mob.hasStatus("slowed"))
					affected_mob.changeStatus("slowed", 6 SECONDS)
					boutput(affected_mob, SPAN_ALERT("You feel [pick("tired", "exhausted", "sluggish")]."))
				else if (prob(4))
					affected_mob.change_eye_blurry(rand(7, 10))
					boutput(affected_mob, SPAN_ALERT("Your vision blurs, you REALLY need some [D.associated_reagent]."))
				else if (prob(20))
					affected_mob.nauseate(1)
			if (prob(8))
				affected_mob.emote(pick("twitch", "twitch_s", "shiver"))
			if (prob(4))
				boutput(affected_mob, SPAN_ALERT("Your head is killing you!"))
			if (prob(5))
				boutput(affected_mob, SPAN_ALERT("You feel like you can't live without [D.associated_reagent]!"))
			else if (prob(5))
				boutput(affected_mob, SPAN_ALERT("You would DIE for some [D.associated_reagent] right now!"))
