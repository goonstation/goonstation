/datum/element/lifeprocess/ranch/age/process(mob/living/critter/small_animal/ranch_base/target, mult, datum/gas_mixture/environment)
	if (target.reagents.has_reagent("ageinium"))
		target.age += mult * 2

	else if (target.reagents.has_reagent("deageinium"))
		if (target.age > 10)
			target.age -= mult

	else if (target.named)
		target.age += mult / 20

	else
		target.age += mult

	if ((target.age > 100) && (target.stage == RANCH_STAGE_CHILD))
		target.grow_up()
		target.after_grow_up()

	if (!target.immortal)
		var/old_age = clamp(500 + (target.happiness * 3) + (target.ageless * 50), 300, 800)
		if ((target.age > old_age) && (target.stage == RANCH_STAGE_ADULT))
			target.grow_old()

		var/max_age = clamp(800 + (target.happiness * 2), 600, 2000 + (100 * target.ageless))
		if ((target.age > max_age) && (target.stage == RANCH_STAGE_SENIOR))
			target.die_of_old_age()
