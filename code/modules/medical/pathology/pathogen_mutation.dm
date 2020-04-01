#define MUTATION_MALICIOUS 1
#define MUTATION_BENEVOLENT -1

#define MUTATION_EVOLUTION 1
#define MUTATION_DEVOLUTION -1

/**
 * Pathogen Mutations
 *
 * All possible mutation effects are a child of /datum/pathogen_mutation.
 * These will be automatically chosen at random as candidates for mutation.
 * There are a number of factors deciding whether or not a certain kind of mutation will occur. If a mutation's criteria are not satisfied,
 * new mutations are chosen until one with satisfied criteria is found. The default mutations are defined so that no situation may arise
 * where a mutation cannot be picked. Regardless, if all mutations defined are unsatisfied, a mutation will not occur.
 *
 * Each mutation may occur exactly session_maximum times per mutation session.
 * This is in to prevent abusing the mutation system for gathering a large amount of symptoms quickly.
 * Symptom gaining mutations are also purposefully made harder to gain very deadly symptoms.
 *
 * Mutation criteria for malicious mutations:
 * - For a malicious mutation to occur on a pathogen, its maliciousness must be greater or equal to the mutation's maliciousness threshold.
 * - For this mutation to occur, its maliciousness must be no greater than its maliciousness limit, unless the limit is lower than the
 *   threshold.
 * - For this mutation to occur, the pathogen's mutativeness must be greater than the mutativeness threshold if it's an evolution, or
 *   lower than the mutativeness threshold if it's a devolution. It may also occur on equality.
 * - If all the above criteria are satisfied, the chance of this mutation actually occurring is
 *   chance_base + maliciousness * chance_modifier
 *
 * Mutation criteria for benevolent mutations:
 * - For a benevolent mutation to occur on a pathogen, its maliciousness must be less or equal to the mutation's maliciousness threshold.
 * - For this mutation to occur, its maliciousness must be no less than its maliciousness limit, unless the limit is higher than the
 *   threshold.
 * - For this mutation to occur, the pathogen's mutativeness must be greater than the mutativeness threshold if it's an evolution, or
 *   lower than the mutativeness threshold if it's a devolution. It may also occur on equality.
 * - If all the above criteria are satisfied, the chance of this mutation actually occurring is
 *   chance_base - maliciousness * chance_modifier
 *
 * The mutation code must be in the mutate proc of the child type. It will be executed automatically if the mutation occurs.
 */

datum/pathogen_mutation
	var/name = "Pathogen Mutation"
	var/desc = "Generic mutation"
	var/malicious_type = MUTATION_MALICIOUS
	var/maliciousness_threshold = 0
	var/maliciousness_limit = -1

	var/session_maximum = 1

	var/chance_base = 50
	var/chance_modifier = 0

	var/evolution_type = MUTATION_EVOLUTION
	var/mutativeness_threshold = 0

	proc/may_occur(var/datum/pathogen/P)
		if (malicious_type * P.maliciousness >= malicious_type * maliciousness_threshold && (malicious_type * maliciousness_limit < malicious_type * maliciousness_threshold || malicious_type * P.maliciousness <= malicious_type * maliciousness_limit) && evolution_type * P.mutativeness >= evolution_type * mutativeness_threshold)
			if (prob(chance_base + malicious_type * P.maliciousness * chance_modifier))
				return 1
		return 0

	proc/mutate(var/datum/pathogen/P)
		return

// This mutation is a general purpose mutation which acts as a "mutation sink" - it absorbs mutations from the pool by existing and
// occurring. This is mostly here for balance purposes.
datum/pathogen_mutation/scramble
	name = "Attribute Scramble"
	desc = "Modifies the five primary attributes of a pathogen by an amount."
	malicious_type = MUTATION_MALICIOUS
	session_maximum = 5
	evolution_type = MUTATION_DEVOLUTION
	may_occur(var/datum/pathogen/P)
		return P.symptomatic && prob(20)

	mutate(var/datum/pathogen/P)
		var/factor = rand(1, 4)
		P.mutativeness = P.mutativeness + factor * rand(-2, 2)
		P.maliciousness = P.maliciousness + factor * rand(-2, 2)
		P.suppression_threshold = P.suppression_threshold + factor * rand(-2, 2)
		P.advance_speed = P.advance_speed + factor * rand(-2, 2)
		P.mutation_speed = P.mutation_speed + factor * rand(-2, 2)

// This mutation exists to introduce a risk factor to getting mutations. Before this, mutations carried the pathogen in the desired
// direction.
datum/pathogen_mutation/lose_attributes
	name = "Lose All Attributes"
	desc = "Sets all five primary attributes of a pathogen to 0."
	malicious_type = MUTATION_MALICIOUS
	evolution_type = MUTATION_DEVOLUTION

	may_occur(var/datum/pathogen/P)
		return P.symptomatic && prob(8)

	mutate(var/datum/pathogen/P)
		P.mutativeness = 0
		P.maliciousness = 0
		P.suppression_threshold = 0
		P.advance_speed = 0
		P.mutation_speed = 0

datum/pathogen_mutation/increase_generation
	name = "Increase Generation"
	desc = "Advances a pathogen to the next generation. Higher generation pathogens may overtake a lower generation infection of the same strain."
	malicious_type = MUTATION_BENEVOLENT
	evolution_type = MUTATION_EVOLUTION

	may_occur(var/datum/pathogen/P)
		return 1

	mutate(var/datum/pathogen/P)
		P.generation++

datum/pathogen_mutation/become_asymptomatic
	name = "Become Asymptomatic"
	desc = "The mutated strain becomes asymptomatic."
	malicious_type = MUTATION_BENEVOLENT
	evolution_type = MUTATION_DEVOLUTION

	may_occur(var/datum/pathogen/P)
		return P.symptomatic && prob(35)

	mutate(var/datum/pathogen/P)
		P.symptomatic = 0

datum/pathogen_mutation/become_symptomatic
	name = "Become Symptomatic"
	desc = "The mutated strain becomes symptomatic."
	malicious_type = MUTATION_MALICIOUS
	evolution_type = MUTATION_EVOLUTION

	may_occur(var/datum/pathogen/P)
		return !P.symptomatic

	mutate(var/datum/pathogen/P)
		P.symptomatic = 1

datum/pathogen_mutation/maliciousness_boost
	name = "Maliciousness Boost"
	desc = "Increases the maliciousness primary attribute of a pathogen."
	malicious_type = MUTATION_MALICIOUS
	maliciousness_threshold = -25
	maliciousness_limit = 5

	chance_base = 75
	chance_modifier = -5

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		if (P.symptomatic)
			return ..()
		return 0

	mutate(var/datum/pathogen/P)
		P.maliciousness += rand(1,3)

datum/pathogen_mutation/benevolence_boost
	name = "Benevolence Boost"
	desc = "Reduces the maliciousness primary attribute of a pathogen."
	malicious_type = MUTATION_BENEVOLENT
	maliciousness_threshold = 25
	maliciousness_limit = -5

	chance_base = 75
	chance_modifier = -5

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		if (P.symptomatic)
			return ..()
		return 0

	mutate(var/datum/pathogen/P)
		P.maliciousness -= rand(1,3)

datum/pathogen_mutation/advance_boost
	name = "Advance Speed Boost"
	desc = "Increases the advance speed primary attribute of a pathogen."
	malicious_type = MUTATION_MALICIOUS
	maliciousness_threshold = 15
	maliciousness_limit = 14

	chance_base = 50
	chance_modifier = 5

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		if (P.symptomatic)
			return ..()
		return 0

	mutate(var/datum/pathogen/P)
		P.advance_speed += rand(1,3)

datum/pathogen_mutation/advance_penalty
	name = "Advance Speed Penalty"
	desc = "Decreases the advance speed primary attribute of a pathogen."
	malicious_type = MUTATION_BENEVOLENT
	maliciousness_threshold = 20
	maliciousness_limit = 21

	chance_base = 50
	chance_modifier = 5

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		if (P.symptomatic)
			return ..()
		return 0

	mutate(var/datum/pathogen/P)
		P.advance_speed -= rand(1,3)

datum/pathogen_mutation/mutation_boost
	name = "Mutation Speed Boost"
	desc = "Increases the mutation speed primary attribute of a pathogen."
	malicious_type = MUTATION_MALICIOUS
	maliciousness_threshold = -15
	maliciousness_limit = -16

	chance_base = 50
	chance_modifier = 5

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		if (P.symptomatic)
			return ..()
		return 0

	mutate(var/datum/pathogen/P)
		P.mutation_speed += rand(1,3)

datum/pathogen_mutation/mutation_penalty
	name = "Mutation Speed Penalty"
	desc = "Decreases the mutation speed primary attribute of a pathogen."
	malicious_type = MUTATION_BENEVOLENT
	maliciousness_threshold = 15
	maliciousness_limit = 16

	chance_base = 50
	chance_modifier = 5

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		return P.symptomatic && ..() && P.mutation_speed > 0

	mutate(var/datum/pathogen/P)
		P.mutation_speed -= rand(1,3)
		if (P.mutation_speed < 0)
			P.mutation_speed = 0

datum/pathogen_mutation/increase_stages
	name = "More Stages"
	desc = "Increases the stages cap of a pathogen, up to 5."
	malicious_type = MUTATION_MALICIOUS
	maliciousness_threshold = -25
	maliciousness_limit = -26

	chance_base = 75
	chance_modifier = 0

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		return ..() && P.stages < 5

	mutate(var/datum/pathogen/P)
		P.stages++

datum/pathogen_mutation/decrease_stages
	name = "Less Stages"
	desc = "Decreases the stages cap of a pathogen, down to 3."
	malicious_type = MUTATION_BENEVOLENT
	maliciousness_threshold = 25
	maliciousness_limit = 26

	chance_base = 75
	chance_modifier = 0

	evolution_type = MUTATION_DEVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		return ..() && P.stages > 3

	mutate(var/datum/pathogen/P)
		P.stages--
		P.stage = min(P.stage, P.stages)

datum/pathogen_mutation/gain_symptom
	name = "Gain Symptom"
	desc = "Adds a new symptom to the pathogen."
	malicious_type = MUTATION_MALICIOUS
	maliciousness_threshold = 15
	maliciousness_limit = 30

	chance_base = 40
	chance_modifier = 8

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		return P.symptomatic && ..()

	mutate(var/datum/pathogen/P)
		var/retries = 10
		while (!P.generate_effect() && retries)
			retries--

datum/pathogen_mutation/gain_more_symptoms
	name = "Gain More Symptoms"
	desc = "Adds up to 3 new symptoms to the pathogen."
	malicious_type = MUTATION_MALICIOUS
	maliciousness_threshold = 25
	maliciousness_limit = 70

	chance_base = 40
	chance_modifier = 8

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		return P.symptomatic && ..()

	mutate(var/datum/pathogen/P)
		var/retries = 10
		for (var/i = 1, i <= rand(1,3), i++)
			while (!P.generate_effect() && retries)
				retries--

datum/pathogen_mutation/gain_strong_symptom
	name = "Gain Strong Symptom"
	desc = "Adds a new strong symptom to the pathogen."
	malicious_type = MUTATION_MALICIOUS
	maliciousness_threshold = 65
	maliciousness_limit = 150

	chance_base = 20
	chance_modifier = 8

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		return P.symptomatic && ..()

	mutate(var/datum/pathogen/P)
		var/retries = 10
		while (!P.generate_strong_effect() && retries)
			retries--

datum/pathogen_mutation/gain_more_strong_symptoms
	name = "Gain More Strong Symptoms"
	desc = "Adds up to 3 new strong symptoms to the pathogen."
	malicious_type = MUTATION_MALICIOUS
	maliciousness_threshold = 125
	maliciousness_limit = 100

	chance_base = 10
	chance_modifier = 1

	evolution_type = MUTATION_EVOLUTION
	mutativeness_threshold = 0

	may_occur(var/datum/pathogen/P)
		return P.symptomatic && ..()

	mutate(var/datum/pathogen/P)
		var/retries = 10
		for (var/i = 1, i <= rand(1,3), i++)
			while (!P.generate_strong_effect() && retries)
				retries--

datum/pathogen_mutation/lose_symptom
	name = "Lose Symptom"
	desc = "Removes a symptom from the pathogen."
	malicious_type = MUTATION_BENEVOLENT
	maliciousness_threshold = 50
	maliciousness_limit = 51

	chance_base = 40
	chance_modifier = 8

	evolution_type = MUTATION_DEVOLUTION
	mutativeness_threshold = 25

	may_occur(var/datum/pathogen/P)
		return P.symptomatic && ..() && P.effects.len

	mutate(var/datum/pathogen/P)
		P.remove_symptom(pick(P.effects))

/*datum/pathogen_mutation/become_alternative
	name = "Become Alternative"
	desc = "A symptom of the pathogen may interchange itself with a more serious, or a milder alternative."

	malicious_type = MUTATION_MALICIOUS
	session_maximum = 3

	may_occur(var/datum/pathogen/P)
		if (!P.symptomatic || P.maliciousness == 0 || P.mutativeness < 5)
			return 0
		else
			for (var/datum/pathogeneffects/E in P.effects)
				if (P.maliciousness > 0)
					if (E.serious_alternatives.len)*/
