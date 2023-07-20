/datum/ailment/disease/leprosy
	name = "Leprosy"
	max_stages = 5
	spread = "Non-Contagious"
	resistance_prob = 100
	cure = "Antibiotics"
	reagentcure = list("spaceacillin")
	recureprob = 100
	associated_reagent = "mycobacterium leprae"
	affected_species = list("Human")
	stage_prob = 3

/datum/ailment/disease/leprosy/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(3)
			if(probmult(0.1))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
			if(probmult(15))
				boutput(affected_mob, pick("<span class='alert'>You feel a bit loose...</span>", \
				"<span class='alert'>You feel like you're falling apart.</span>"))
		if(4 to 5)
			if(probmult(0.1))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
			if(probmult(D.stage) && ishuman(affected_mob))
				var/mob/living/carbon/human/M = affected_mob
				var/limb_name = pick("l_arm","r_arm","l_leg","r_leg")
				var/obj/item/parts/limb = M.limbs.vars[limb_name]
				if (istype(limb))
					if (limb.remove_stage < 2)
						limb.remove_stage = 2
						M.show_message("<span class='alert'>Your [limb] comes loose!</span>")
						SPAWN(rand(15,20) SECONDS)
							if(limb.remove_stage == 2)
								limb.remove(0)
