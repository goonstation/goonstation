/// Lower bound for the apparition encounter chance at the disease's final stage
#define THIRD_SHIFT_APPARITION_CHANCE_MIN 15
/// Upper bound for the apparition encounter chance at the disease's final stage
#define THIRD_SHIFT_APPARITION_CHANCE_MAX 30

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
	if (D.stage >= 4)
		var/encounter_chance = 10
		if (D.stage >= 5)
			encounter_chance = rand(THIRD_SHIFT_APPARITION_CHANCE_MIN, THIRD_SHIFT_APPARITION_CHANCE_MAX)
		affected_mob.AddComponent(/datum/component/crew_apparitions, encounter_chance, 10, 1)

/// Remove the disease's apparition effect when its strain is cured
/datum/ailment/disease/third_shift_syndrome/on_remove(mob/living/affected_mob, datum/ailment_data/disease/D)
	affected_mob?.RemoveComponentsOfType(/datum/component/crew_apparitions)
	..()

#undef THIRD_SHIFT_APPARITION_CHANCE_MIN
#undef THIRD_SHIFT_APPARITION_CHANCE_MAX
