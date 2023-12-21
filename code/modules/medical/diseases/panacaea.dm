/datum/ailment/disease/panacaea
	name = "Panacaea"
	max_stages = 2
	spread = "Airborne"
	cure_flags = CURE_CUSTOM
	cure_desc = "Self-curing"
	associated_reagent = "viral curative"
	affected_species = list("Human", "Monkey", "Alien")

//
/datum/ailment/disease/panacaea/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(1)
			if (probmult(8))
				boutput(affected_mob, SPAN_NOTICE("You feel refreshed."))
				affected_mob.HealDamage("All", 2, 2)
				affected_mob.take_toxin_damage(-2)
			if (probmult(8))
				var/procmessage = pick("You feel very healthy.","All your aches and pains fade.","You feel really good!")
				boutput(affected_mob, SPAN_NOTICE("[procmessage]"))
		if(2)
			if (probmult(8))
				var/procmessage = pick("You feel very healthy.","All your aches and pains fade.","You feel really good!")
				boutput(affected_mob, SPAN_NOTICE("[procmessage]"))
			if (probmult(8))
				boutput(affected_mob, SPAN_NOTICE("You feel refreshed."))
				affected_mob.HealDamage("All", 2, 2)
				affected_mob.take_toxin_damage(-2)
			if(probmult(10))
				for (var/datum/ailment_data/disease/V in affected_mob.ailments)
					if (istype(V.master, /datum/ailment/disease/panacaea))
						continue
					affected_mob.cure_disease(V)
