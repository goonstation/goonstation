/datum/element/lifeprocess/ranch/hunger/process(mob/living/critter/small_animal/ranch_base/target, mult, datum/gas_mixture/environment)
	var/hunger_increase = max(round(mult / 2, 1), 1)
	if (target.named)
		target.hunger += hunger_increase / 20
	else
		target.hunger += hunger_increase

	if ((target.hunger > 150) && !target.immortal)
		target.die_of_hunger()
	if (target.hunger > 30)
		target.change_happiness(-abs(target.happiness / 3))
