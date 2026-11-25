/datum/element/lifeprocess/organs/process(mob/living/target, mult, datum/gas_mixture/environment)
	if (isdead(target))
		return

	target.handle_organs(mult)
