
/datum/ailment/disease/high_fever
	name = "High Fever"
	max_stages = 5
	stage_prob = 10
	cure = "ice"
	reagentcure = list("ice")

	associated_reagent = "too much"
	affected_species = list("Human")

/datum/ailment/disease/high_fever/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(10))
				boutput(affected_mob, "<span class='alert'>Its getting warm around here...</span>")
				affected_mob.bodytemperature += 5
		if(3)
			if(probmult(10))
				boutput(affected_mob, "<span class='alert'>You're starting to heat up...</span>")
				affected_mob.bodytemperature += 10
		if(4)
			if(probmult(10))
				boutput(affected_mob, "<span class='alert'>You're REALLY starting to heat up...</span>")
				affected_mob.bodytemperature += 15

		if(5)
			boutput(affected_mob, "<span class='alert'>You're a hundred and one!</span>")
			var/mob/living/carbon/human/H = affected_mob
			if(H.limbs != null)
				H.limbs.replace_with("l_arm", /obj/item/parts/human_parts/arm/left/hot, null , 0)
				H.limbs.replace_with("r_arm", /obj/item/parts/human_parts/arm/right/hot, null , 0)
				H.limbs.l_arm.holder = H
				H.limbs.r_arm.holder = H
				H.update_body()
			D.stage_prob = 0
			D.stage = 1


