/datum/ailment/disease/tissue_necrosis
	name = "Tissue Necrosis"
	max_stages = 5
	spread = "Non-Contagious"
	cure = "Formaldehyde"
	associated_reagent = "rotting"
	affected_species = list("Human")
	reagentcure = list("formaldehyde")
	recureprob = 10

/datum/ailment/disease/tissue_necrosis/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if (D.stage > 1)
		if (affected_mob:decomp_stage != D.stage - 1)
			affected_mob:decomp_stage = D.stage - 1
			affected_mob.show_message("<span class='alert'>You feel [pick("very", "rather", "a bit", "terribly", "stinkingly")] rotten!</span>")
			affected_mob.update_body()
			affected_mob.update_face()

/datum/ailment/disease/tissue_necrosis/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/D)
	affected_mob:decomp_stage = DECOMP_STAGE_NO_ROT
	..()

