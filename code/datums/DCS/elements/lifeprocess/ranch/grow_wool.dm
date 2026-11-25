/datum/element/lifeprocess/ranch/sheep/grow_wool/process(mob/living/critter/small_animal/ranch_base/sheep/target, mult, datum/gas_mixture/environment)
	if (target.stage == RANCH_STAGE_CHILD)
		return

	if (target.wool_grown)
		target.wool_counter = 0
		return

	target.wool_counter += mult
	switch (target.wool_counter)
		if (30 to 100)
			var/happiness = clamp(target.happiness, 0, 100)
			var/hunger = clamp(((target.hunger - 25) * 2) + target.wool_counter, 0, 100)
			var/chance = max(happiness - hunger, 20)

			if (prob(chance))
				target.grow_wool()

		if (100 to INFINITY)
			target.grow_wool()
