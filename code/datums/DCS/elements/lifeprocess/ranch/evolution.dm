/datum/element/lifeprocess/ranch/evolution/process(mob/living/critter/small_animal/ranch_base/target, mult, datum/gas_mixture/environment)
	for (var/datum/ranch/evolution/E as anything in target.evolutions)
		var/datum/ranch/evolution/current = target.evolved
		if ((current == E) || !E.check_evolution_conditions(target))
			continue

		if ( \
			!current \
			|| (current == target.base_evolution) \
			|| (current.evolution_priority <= E.evolution_priority) \
		)
			E.evolve(target)

	if (target.base_evolution && !target.evolved?.check_evolution_conditions(target))
		target.base_evolution.evolve(target)
