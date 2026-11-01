
/datum/ailment/disease/high_fever
	name = "High Fever"
	max_stages = 5
	stage_prob = 10
	cure_flags = CURE_CUSTOM
	cure_desc = "Ice"
	reagentcure = list("ice")
	var/transformed = FALSE // Did we change the arms yet?

	associated_reagent = "too much"
	affected_species = list("Human")

/datum/ailment/disease/high_fever/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(10))
				boutput(affected_mob, SPAN_ALERT("Its getting warm around here..."))
				affected_mob.changeBodyTemp(20 KELVIN)
		if(3)
			if(probmult(10))
				boutput(affected_mob, SPAN_ALERT("You're starting to heat up..."))
				affected_mob.changeBodyTemp(25 KELVIN)
		if(4)
			if(probmult(10))
				boutput(affected_mob, SPAN_ALERT("You're REALLY starting to heat up..."))
				affected_mob.changeBodyTemp(30 KELVIN)

		if(5)
			boutput(affected_mob, SPAN_ALERT("You're a hundred and one!"))
			affected_mob.changeBodyTemp(45 KELVIN)
			var/mob/living/carbon/human/H = affected_mob
			if(transformed)
				H.update_burning(5)
			if(H.limbs != null && !transformed)
				H.limbs.replace_with("l_arm", /obj/item/parts/human_parts/arm/left/hot, null , 0)
				H.limbs.replace_with("r_arm", /obj/item/parts/human_parts/arm/right/hot, null , 0)
				H.limbs.l_arm.holder = H
				H.limbs.r_arm.holder = H
				H.update_body()
				transformed = TRUE
			D.stage_prob = 10
			D.stage = 1


