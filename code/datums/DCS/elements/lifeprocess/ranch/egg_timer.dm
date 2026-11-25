/datum/element/lifeprocess/ranch/chicken/egg_timer/process(mob/living/critter/small_animal/ranch_base/chicken/target, mult, datum/gas_mixture/environment)
	if (target.named)
		target.egg_timer = max(0, target.egg_timer - (mult / 20))
	else
		target.egg_timer = max(0, target.egg_timer - mult)
