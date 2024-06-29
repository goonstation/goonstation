/datum/ailment/disease/leprosy
	name = "Leprosy"
	max_stages = 5
	spread = "Non-Contagious"
	resistance_prob = 100
	cure_flags = CURE_ANTIBIOTICS
	associated_reagent = "mycobacterium leprae"
	affected_species = list("Human")
	stage_prob = 3

/datum/ailment/disease/leprosy/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(3)
			if(probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.cure_disease(D)
			if(probmult(15))
				boutput(affected_mob, pick(SPAN_ALERT("You feel a bit loose..."), \
				SPAN_ALERT("You feel like you're falling apart.")))
		if(4 to 5)
			if(probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.cure_disease(D)
			if(probmult(D.stage) && ishuman(affected_mob))
				var/mob/living/carbon/human/M = affected_mob
				var/limb_name = pick("l_arm","r_arm","l_leg","r_leg")
				var/obj/item/parts/limb = M.limbs.vars[limb_name]
				if (istype(limb))
					if (limb.remove_stage < 2)
						limb.remove_stage = 2
						M.show_message(SPAN_ALERT("Your [limb] comes loose!"))
						SPAWN(rand(15,20) SECONDS)
							if(limb.remove_stage == 2)
								limb.remove(0)
