/datum/ailment/disease/tissue_necrosis
	name = "Tissue Necrosis"
	max_stages = 5
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Formaldehyde"
	associated_reagent = "rotting"
	affected_species = list("Human")
	reagentcure = list("formaldehyde")
	recureprob = 10

/datum/ailment/disease/tissue_necrosis/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if (D.stage > 1)
		if(ishuman(affected_mob))
			var/mob/living/carbon/human/H = affected_mob
			if (H.decomp_stage != D.stage - 1)
				H.decomp_stage = D.stage - 1
				H.show_message(SPAN_ALERT("You feel [pick("very", "rather", "a bit", "terribly", "stinkingly")] rotten!"))
				H.update_body()
				H.update_face()

/datum/ailment/disease/tissue_necrosis/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if(ishuman(affected_mob))
			var/mob/living/carbon/human/H = affected_mob
			H.decomp_stage = DECOMP_STAGE_NO_ROT
			if(H.limbs?.l_arm?.decomp_affected)
				H.limbs.l_arm.current_decomp_stage = DECOMP_STAGE_NO_ROT
			if(H.limbs?.r_arm?.decomp_affected)
				H.limbs.r_arm.current_decomp_stage = DECOMP_STAGE_NO_ROT
			if(H.limbs?.l_leg?.decomp_affected)
				H.limbs.l_leg.current_decomp_stage = DECOMP_STAGE_NO_ROT
			if(H.limbs?.r_leg?.decomp_affected)
				H.limbs.r_leg.current_decomp_stage = DECOMP_STAGE_NO_ROT
	..()

