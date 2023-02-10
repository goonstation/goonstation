// Addiction with comically-exaggerated withdrawal effects!

/datum/ailment/addiction
	name = "reagent addiction"
	scantype = "Chemical Dependency"
	max_stages = 5
	cure = "Time"
	affected_species = list("Human")

/datum/ailment/addiction/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/addiction/D, mult)
	if (..())
		return
	if (prob(20) && (world.timeofday > (D.last_reagent_dose + D.withdrawal_duration)))
		boutput(affected_mob, "<span class='notice'>You no longer feel reliant on [D.associated_reagent]!</span>")
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
				boutput(affected_mob, "<span class='notice'>You feel a dull headache.</span>")
		if (3)
			if (prob(8))
				affected_mob.emote("twitch_s")
			if (prob(8))
				affected_mob.emote("shiver")
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>Your head hurts.</span>")
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>You begin craving [D.associated_reagent]!</span>")
		if (4)
			if (prob(8))
				affected_mob.emote("twitch")
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>You have a pounding headache.</span>")
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>You have the strong urge for some [D.associated_reagent]!</span>")
			else if (prob(4))
				boutput(affected_mob, "<span class='alert'>You REALLY crave some [D.associated_reagent]!</span>")
		if (5)
			if (D.max_severity == "LOW")
				if (prob(6))
					affected_mob.changeStatus("slowed", 3 SECONDS)
					boutput(affected_mob, "<span class='alert'>You feel [pick("tired", "exhausted", "sluggish")].</span>")
			else // D.max_severity is HIGH or whatever
				if (prob(6))
					if (affected_mob.nutrition > 10)
						affected_mob.visible_message("<span class='alert'>[affected_mob] vomits on the floor profusely!</span>",\
						"<span class='alert'>You vomit all over the floor!</span>")
						affected_mob.vomit(rand(3,5))
					else
						affected_mob.visible_message("<span class='alert'>[affected_mob] gags and retches!</span>",\
						"<span class='alert'>Your stomach lurches painfully!</span>")
						affected_mob.changeStatus("stunned", 2 SECONDS)
						affected_mob.changeStatus("weakened", 2 SECONDS)
			if (prob(8))
				affected_mob.emote(pick("twitch", "twitch_s", "shiver"))
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>Your head is killing you!</span>")
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>You feel like you can't live without [D.associated_reagent]!</span>")
			else if (prob(5))
				boutput(affected_mob, "<span class='alert'>You would DIE for some [D.associated_reagent] right now!</span>")
