/datum/ailment/malady/bloodclot
	name = "Blood Clot"
	scantype = "Potential Medical Emergency"
	max_stages = 1
	info = "The patient has a blood clot."
	cure_flags = CURE_MEDICINE
	cure_desc = "Anticoagulants"
	reagentcure = list("heparin"=10)
	affected_species = list("Human","Monkey")
	stage_advance_prob = 5

/datum/ailment/malady/bloodclot/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/malady/D)
	..()
	if (D)
		D.state = AILMENT_STATE_ASYMPTOMATIC // not doing anything at first

/datum/ailment/malady/bloodclot/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/malady/D)
	..()
	if (iscarbon(affected_mob))
		var/mob/living/carbon/C = affected_mob
		REMOVE_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot")
		C.remove_stam_mod_max("bloodclot")

/datum/ailment/malady/bloodclot/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
	if (D?.state == AILMENT_STATE_ASYMPTOMATIC)
		if (prob(1) && (prob(1) || affected_mob.find_ailment_by_type(/datum/ailment/malady/heartdisease) || affected_mob.reagents && affected_mob.reagents.has_reagent("proconvertin"))) // very low prob to become...
			D.state = AILMENT_STATE_ACTIVE
			D.scantype = "Medical Emergency"
	if (..())
		return
	if (D?.state == AILMENT_STATE_ACTIVE)
		if (!ishuman(affected_mob))
			affected_mob.cure_disease(D)
			return
		var/mob/living/carbon/human/H = affected_mob
		if (!D.affected_area && probmult(20))
			var/list/possible_areas = list()
			if (H.organHolder)
				if (H.organHolder.heart)
					possible_areas += "chest"
				if (H.organHolder.brain)
					possible_areas += "head"
			if (H.limbs)
				if (H.limbs.l_arm)
					possible_areas += "left arm"
				if (H.limbs.r_arm)
					possible_areas += "right arm"
				if (H.limbs.l_leg)
					possible_areas += "left leg"
				if (H.limbs.r_leg)
					possible_areas += "right leg"
			D.affected_area = pick(possible_areas)
			if (!D.affected_area)
				affected_mob.cure_disease(D)
				return
			boutput(affected_mob, SPAN_ALERT("Your [D.affected_area] starts hurting!"))
		else if (probmult(3))
			boutput(affected_mob, SPAN_ALERT("Your [D.affected_area] hurts!"))

		switch (D.affected_area)
			if ("chest")
				if (H.organHolder && !H.organHolder.heart) // you need a heart to have an embolism in it
					affected_mob.cure_disease(D)
					return
				if (probmult(5) && iscarbon(affected_mob))
					var/mob/living/carbon/C = affected_mob
					APPLY_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot", -2)
					C.add_stam_mod_max("bloodclot", -10)
				if (probmult(5))
					affected_mob.losebreath ++
				if (probmult(5))
					affected_mob.take_oxygen_deprivation(rand(1,2))
				if (probmult(5))
					affected_mob?.organHolder.damage_organ(tox=2*mult, organ="heart")
				if (probmult(5))
					affected_mob.emote(pick("twitch", "groan", "gasp"))
				if (probmult(1))
					affected_mob.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
			if ("head")
				if (H.organHolder && !H.organHolder.head || !H.organHolder.brain) // you need a brain to have an embolism in it
					affected_mob.cure_disease(D)
					return
				if (probmult(5) && iscarbon(affected_mob))
					var/mob/living/carbon/C = affected_mob
					APPLY_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot", -2)
					C.add_stam_mod_max("bloodclot", -10)
				if (probmult(8))
					affected_mob.take_brain_damage(10)
				if (probmult(5))
					affected_mob.stuttering += 1
				if (probmult(2))
					affected_mob.changeStatus("drowsy", 5 SECONDS)
				if (probmult(5))
					affected_mob.emote(pick("faint", "collapse", "twitch", "groan"))
			else // a limb or whatever
				if (H.limbs)
					if (D.affected_area == "left arm" && !H.limbs.l_arm)
						affected_mob.cure_disease(D)
						return
					else if (D.affected_area == "right arm" && !H.limbs.r_arm)
						affected_mob.cure_disease(D)
						return
					else if (D.affected_area == "left leg" && !H.limbs.l_leg)
						affected_mob.cure_disease(D)
						return
					else if (D.affected_area == "right leg" && !H.limbs.r_leg)
						affected_mob.cure_disease(D)
						return
				if (probmult(2)) // the clot moves
					boutput(affected_mob, SPAN_NOTICE("Your [D.affected_area] stops hurting."))
					if (prob(1))
						affected_mob.cure_disease(D)
						return
					D.affected_area = null
					if (iscarbon(affected_mob))
						var/mob/living/carbon/C = affected_mob
						REMOVE_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot")
						C.remove_stam_mod_max("bloodclot")
