/datum/element/lifeprocess/organs/process(mob/living/target, datum/gas_mixture/environment)
	if (isdead(target))
		return

	var/mult = src.get_multiplier(target)
	target.handle_organs(mult)
