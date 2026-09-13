/datum/ailment/disease/third_shift_syndrome
	name = "Third Shift Syndrome"
	scantype = "Psychological Condition"
	max_stages = 5
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Haloperidol"
	reagentcure = list("haloperidol")
	associated_reagent = "phantom_payroll"
	affected_species = list("Human")

/datum/ailment/disease/third_shift_syndrome/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/disease/D, mult)
	if (..())
		return

	var/previous_stage = D.strain_data["third_shift_syndrome_stage"]
	if (D.stage < 4)
		return

	if (D.stage == previous_stage)
		return

	var/encounter_chance = D.stage >= 5 ? 25 : 10
	affected_mob.AddComponent(/datum/component/crew_apparitions, encounter_chance, 10, 1)
	D.strain_data["third_shift_syndrome_stage"] = D.stage

/// Remove the disease's apparition effect when its strain is cured
/datum/ailment/disease/third_shift_syndrome/on_remove(mob/living/affected_mob, datum/ailment_data/disease/D)
	affected_mob?.RemoveComponentsOfType(/datum/component/crew_apparitions)
	..()
