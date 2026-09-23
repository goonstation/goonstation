/// Minimum caffeine amount that lets progression rolls reduce Third Shift Syndrome's stage
#define THIRD_SHIFT_SYNDROME_CAFFEINE_THRESHOLD 1

/datum/ailment/disease/third_shift_syndrome
	name = "Third Shift Syndrome"
	scantype = "Psychological Condition"
	max_stages = 5
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Haloperidol"
	reagentcure = list("haloperidol")
	reagent_suppressants = list("caffeine" = THIRD_SHIFT_SYNDROME_CAFFEINE_THRESHOLD)
	suppression_linger_duration = 5 MINUTES
	associated_reagent = "phantom_payroll"
	affected_species = list("Human")

/datum/ailment/disease/third_shift_syndrome/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/disease/D, mult)
	if (..())
		return
	var/previous_stage = D.strain_data["third_shift_syndrome_stage"]
	if (D.stage != previous_stage)
		src.update_apparition_effect(affected_mob, D, previous_stage)

/datum/ailment/disease/third_shift_syndrome/on_infection(mob/living/affected_mob, datum/ailment_data/disease/D)
	..()
	src.update_apparition_effect(affected_mob, D)

/datum/ailment/disease/third_shift_syndrome/on_stage_change(mob/living/affected_mob, datum/ailment_data/disease/D, previous_stage)
	..()
	src.update_apparition_effect(affected_mob, D, previous_stage)

/// Reconcile the apparition component with the syndrome's current stage
/datum/ailment/disease/third_shift_syndrome/proc/update_apparition_effect(mob/living/affected_mob, datum/ailment_data/disease/D, previous_stage)
	if (D.state == "Asymptomatic" || D.state == "Dormant")
		if (previous_stage >= 4)
			affected_mob.RemoveComponentsOfType(/datum/component/crew_apparitions)
		return

	if (D.stage < 4)
		if (previous_stage >= 4)
			affected_mob.RemoveComponentsOfType(/datum/component/crew_apparitions)
		D.strain_data["third_shift_syndrome_stage"] = D.stage
		return

	var/encounter_chance = D.stage >= 5 ? 25 : 10
	affected_mob.AddComponent(/datum/component/crew_apparitions, encounter_chance, 10, 1)
	D.strain_data["third_shift_syndrome_stage"] = D.stage

/// Remove the disease's apparition effect when its strain is cured
/datum/ailment/disease/third_shift_syndrome/on_remove(mob/living/affected_mob, datum/ailment_data/disease/D)
	affected_mob?.RemoveComponentsOfType(/datum/component/crew_apparitions)
	..()

#undef THIRD_SHIFT_SYNDROME_CAFFEINE_THRESHOLD
