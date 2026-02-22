/datum/ailment/disease/lungrot
	name = "Lungrot"
	max_stages = 5
	stage_prob = 4
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Robustissin application after removal of salbutamol."
	associated_reagent = "lungrot_bloom"
	reagentcure = list("cold_medicine")
	//for as long as salbutamol is in the patient, robustissin is extremly ineffective
	recureprob = 1
	affected_species = list("Human")



/datum/ailment/disease/lungrot/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/affecting_ailment, mult)
	//if salbutamol is out of the person, increase the cure chance by a lot
	if (affected_mob.reagents?.get_reagent_amount("salbutamol") > 0)
		affecting_ailment.recureprob = 1
	else
		affecting_ailment.recureprob = 20

	//if remissive, we deduct 2 stages from the disease. It should be significantly weaker, but not instantly gone on cure.
	var/effective_ailment_stage = affecting_ailment.stage
	if (affecting_ailment.state == "Remissive")
		effective_ailment_stage -= 2

	if (effective_ailment_stage > 0)
		var/tox_damage_to_deal = 0.2 //how much damage does this deal on this stage
		var/miasma_to_add = 0.6 //how much miasma does this generate in the victim at this stage
		var/chance_for_breath = 0 //how high is the chance to cough out miasma
		var/miasma_to_breath = 0 //how much miasma is emitted each cough
		switch(effective_ailment_stage)
			//We defined the values for stage one at the beginning
			if(2)
				miasma_to_add = 0.8
				tox_damage_to_deal = 0.4
				chance_for_breath = 5
				miasma_to_breath = rand(3,8)
			if(3)
				miasma_to_add = 1
				tox_damage_to_deal = 0.5
				chance_for_breath = 8
				miasma_to_breath = rand(8,12)
			if(4)
				miasma_to_add = 1.2
				tox_damage_to_deal = 0.5
				chance_for_breath = 12
				miasma_to_breath = rand(12,18)
			if(5)
				miasma_to_add = 1.5
				tox_damage_to_deal = 0.5
				chance_for_breath = 17
				miasma_to_breath = rand(18,28)

		// Now we add the miasma and deal damage
		affected_mob.reagents?.add_reagent("miasma", miasma_to_add * mult)
		affected_mob.take_toxin_damage(tox_damage_to_deal * mult)

		// On later stages, we begin breathing out miasma
		var/did_cough = FALSE
		if (chance_for_breath > 0 && miasma_to_breath > 0)
			if (probmult(chance_for_breath) && (!ON_COOLDOWN(affected_mob, "lungrot_breath", 15 SECONDS)))
				did_cough = TRUE
				var/turf/target_turf = get_turf(affected_mob)
				//We want to smoke the stuff one tile in front of the person, if the space is not occupied by a wall or such
				var/turf/potential_turf = get_step(target_turf, affected_mob.dir)
				if (!potential_turf.density)
					target_turf = potential_turf

				//add some losebreath for a bit more damage and so you don't directly inhale the chemicals you just coughed out
				affected_mob.visible_message("<span class='alert>[affected_mob] coughs out a [pick("nasty","noxious","concerning","rotten")] cloud of miasma!</span>", SPAN_ALERT("You cough out a [pick("nasty","noxious","concerning","rotten")] cloud of miasma!"))
				affected_mob.losebreath += (1 * mult)
				affected_mob.emote("cough")

				// the smoke breathed out is miasma and 35% of this amount out of the chempool in you on top of that.
				var/datum/reagents/reagents_to_smoke = new /datum/reagents(miasma_to_breath * 1.35)
				reagents_to_smoke.add_reagent("miasma", miasma_to_breath)
				affected_mob.reagents.trans_to_direct(reagents_to_smoke, miasma_to_breath * 0.35)

				// now we smoke the stuff and remove the temporary reagent holder
				target_turf.fluid_react(reagents_to_smoke, reagents_to_smoke.total_volume,  airborne = 1)
				qdel(reagents_to_smoke)

		// Once the chance exist we exhale miasma, we give the poor person some messages to warn them for whats about to come
		if (effective_ailment_stage > 1 && !did_cough && probmult(10) && (!ON_COOLDOWN(affected_mob, "lungrot_message", 25 SECONDS)))
			boutput(affected_mob, SPAN_ALERT("You feel [pick("a burning sensation in your lungs", "like it's harder to breath", "a fur-like texture on your tongue")]."))
			affected_mob.organHolder?.damage_organs(tox=2*mult, organs=list("left_lung", "right_lung"))
