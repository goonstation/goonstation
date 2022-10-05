/datum/ailment/disease/chronic_exposure/mercury
	name = "Mercurialism"
	scantype = "heavy metal poisoning"
	max_stages = 3
	spread = "Non-Contagious"
	cure = "EDTA/Chelation Therapy"
	associated_reagent = "mercury"
	affected_species = list("Human","Monkey")

/datum/ailment/disease/chronic_exposure/mercury_poisoning/on_remove(mob/living/affected_mob, datum/ailment_data/D)
	affected_mob.remove_stam_mod_max("mercury_poisoning")
	REMOVE_ATOM_PROPERTY(affected_mob, PROP_MOB_STAMINA_REGEN_BONUS, "mercury_poisoning")
	..()

/datum/ailment/disease/chronic_exposure/mercury/stage_update(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	affected_mob.remove_stam_mod_max("mercury_poisoning")
	REMOVE_ATOM_PROPERTY(affected_mob, PROP_MOB_STAMINA_REGEN_BONUS, "mercury_poisoning")
	switch(D.stage)
		if(1)
			affected_mob.add_stam_mod_max("mercury_poisoning", -40)
			APPLY_ATOM_PROPERTY(affected_mob, PROP_MOB_STAMINA_REGEN_BONUS, "mercury_poisoning", -2)
		if(2)
			affected_mob.add_stam_mod_max("mercury_poisoning", -80)
			APPLY_ATOM_PROPERTY(affected_mob, PROP_MOB_STAMINA_REGEN_BONUS, "mercury_poisoning", -4)
		if(3)
			affected_mob.add_stam_mod_max("mercury_poisoning", -120)
			APPLY_ATOM_PROPERTY(affected_mob, PROP_MOB_STAMINA_REGEN_BONUS, "mercury_poisoning", -6)

/datum/ailment/disease/chronic_exposure/mercury/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	var/mob/living/carbon/human/H = null
	if (ishuman(affected_mob))
		H = affected_mob // we need this to deal with organ stuff (/living doesnt have organ_holder)

	// Also includes reduced melee damage (including stamina damage) by 0.25% * stage
	// (e.g stage 3 = 75% reduction)
	var/obj/item/organ/brain/brain = H.get_organ("brain")
	var/obj/item/organ/kidney/left/L_kidney = H.get_organ("left_kidney")
	var/obj/item/organ/kidney/right/R_kidney = H.get_organ("right_kidney")
	switch(D.stage)
		// minor barely noticeable symptoms
		if(1)
			if(brain && (brain.tox_dam < 20))
				brain.tox_dam += 3
			if(L_kidney && (L_kidney.tox_dam < 10))
				L_kidney.tox_dam += 1
			if(R_kidney && (R_kidney.tox_dam < 10))
				R_kidney.tox_dam += 1

			if(prob(5))
				affected_mob.emote("shiver")
			if(prob(2))
				var/msg = pick(
					"Your head kinda hurts.",
					"You feel a bit nauseous.")
				boutput(affected_mob, "<span class='alert'>[msg]</span>")

		// moderately debilitating effects
		if(2)
			if(brain && (brain.tox_dam < 30))
				brain.tox_dam += 5
			if(L_kidney && (L_kidney.tox_dam < 20))
				L_kidney.tox_dam += 3
			if(R_kidney && (R_kidney.tox_dam < 20))
				R_kidney.tox_dam += 3

			if(prob(5))
				var/msg = pick(
					"Your head aches.",
					"You feel nauseous...",
					"You faintly taste metal.")
				boutput(affected_mob, "<span class='alert'>[msg]</span>")
			else if(prob(3))
				boutput(affected_mob, "<span class='alert'>Your vision blurs.</span>")
				affected_mob.change_eye_blurry(3, 3)
			else if(prob(2))
				boutput(affected_mob, "<span class='alert'>You feel short of breath!</span>")
				affected_mob.lose_breath(1)

			if(prob(4))
				affected_mob.stuttering += 3

			if(prob(1))
				src.puke(affected_mob)

		// severe, debilitating, sorta lethal effects
		if(3)
			if(brain && (brain.tox_dam < 60))
				brain.tox_dam += 8
			if(L_kidney && (L_kidney.tox_dam < 35))
				L_kidney.tox_dam += 5
			if(R_kidney && (R_kidney.tox_dam < 35))
				R_kidney.tox_dam += 5

			if(prob(8))
				var/msg = pick(
					"Your head throbs in pain!",
					"You feel like you're gonna throw up!",
					"You taste metal.")
				boutput(affected_mob, "<span class='alert'>[msg]</span>")
			else if(prob(5))
				boutput(affected_mob, "<span class='alert'>Your vision blurs.</span>")
				affected_mob.change_eye_blurry(5, 5)
			else if(prob(5))
				boutput(affected_mob, "<span class='alert'>You have a hard time breathing!</span>")
				affected_mob.lose_breath(3)

			if(prob(8))
				affected_mob.stuttering += 6

			if(prob(50))
				affected_mob.make_jittery(20)

			if(prob(5))
				src.puke(affected_mob)

			// guaranteed to kill with enough time
			if(prob(2))
				brain.tox_dam += 1
			if(prob(4))
				pick(
					L_kidney.tox_dam += 1,
					R_kidney.tox_dam += 1)

