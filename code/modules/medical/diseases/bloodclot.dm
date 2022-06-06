/*/* -------------------- Blood Clot -------------------- */
/datum/ailment/disease/bloodclot
	name = "Blood Clot"
	scantype = "Potential Medical Emergency"
	max_stages = 1
	spread = "The patient has a blood clot."
	cure = "Anticoagulants"
	reagentcure = list("heparin")
	recureprob = 10
	affected_species = list("Human")
	stage_prob = 0
	var/affected_area = null // can be chest (heart, eventually lung), head (brain), limb

/datum/ailment/disease/bloodclot/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/D)
	..()
	if (D)
		D.state = "Asymptomatic" // not doing anything at first

/datum/ailment/disease/bloodclot/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/D)
	..()
	if (iscarbon(affected_mob))
		var/mob/living/carbon/C = affected_mob
		REMOVE_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot")
		C.remove_stam_mod_max("bloodclot")

/datum/ailment/disease/bloodclot/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (D?.state == "Asymptomatic")
		if (prob(1) && (prob(1) || affected_mob.find_ailment_by_type(/datum/ailment/disease/heartdisease) || affected_mob.reagents && affected_mob.reagents.has_reagent("proconvertin"))) // very low prob to become...
			D.state = "Active"
			D.scantype = "Medical Emergency"
	if (..())
		return
	if (D?.state == "Active")
		if (!ishuman(affected_mob))
			affected_mob.cure_disease(D)
			return
		var/mob/living/carbon/human/H = affected_mob
		if (!src.affected_area && prob(20))
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
			src.affected_area = pick(possible_areas)
			if (!src.affected_area)
				affected_mob.cure_disease(D)
				return
			boutput(affected_mob, "<span class='alert'>Your [src.affected_area] starts hurting!</span>")
		else if (prob(3))
			boutput(affected_mob, "<span class='alert'>Your [src.affected_area] hurts!</span>")

		switch (src.affected_area)
			if ("chest")
				if (H.organHolder && !H.organHolder.heart) // you need a heart to have an embolism in it
					affected_mob.cure_disease(D)
					return
				if (prob(5) && iscarbon(affected_mob))
					var/mob/living/carbon/C = affected_mob
					APPLY_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot", -2)
					C.add_stam_mod_max("bloodclot", -10)
				if (prob(5))
					affected_mob.losebreath ++
				if (prob(5))
					affected_mob.take_oxygen_deprivation(rand(1,2))
				if (prob(5))
					affected_mob.emote(pick("twitch", "groan", "gasp"))
				if (prob(1))
					affected_mob.contract_disease(/datum/ailment/disease/heartfailure,null,null,1)
			if ("head")
				if (H.organHolder && !H.organHolder.head || !H.organHolder.brain) // you need a brain to have an embolism in it
					affected_mob.cure_disease(D)
					return
				if (prob(5) && iscarbon(affected_mob))
					var/mob/living/carbon/C = affected_mob
					APPLY_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot", -2)
					C.add_stam_mod_max("bloodclot", -10)
				if (prob(8))
					affected_mob.take_brain_damage(10)
				if (prob(5))
					affected_mob.stuttering += 1
				if (prob(2))
					affected_mob.changeStatus("drowsy", 1 SECONDS)
				if (prob(5))
					affected_mob.emote(pick("faint", "collapse", "twitch", "groan"))
			else // a limb or whatever
				if (H.limbs)
					if (src.affected_area == "left arm" && !H.limbs.l_arm)
						affected_mob.cure_disease(D)
						return
					else if (src.affected_area == "right arm" && !H.limbs.r_arm)
						affected_mob.cure_disease(D)
						return
					else if (src.affected_area == "left leg" && !H.limbs.l_leg)
						affected_mob.cure_disease(D)
						return
					else if (src.affected_area == "right leg" && !H.limbs.r_leg)
						affected_mob.cure_disease(D)
						return
				if (prob(2)) // the clot moves
					boutput(affected_mob, "<span class='notice'>Your [src.affected_area] stops hurting.</span>")
					if (prob(1))
						affected_mob.cure_disease(D)
						return
					src.affected_area = null
					if (iscarbon(affected_mob))
						var/mob/living/carbon/C = affected_mob
						REMOVE_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot")
						C.remove_stam_mod_max("bloodclot")
*/
