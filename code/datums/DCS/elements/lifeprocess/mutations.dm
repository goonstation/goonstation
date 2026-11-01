/datum/element/lifeprocess/mutations/process(mob/living/target, datum/gas_mixture/environment)
	if (isdead(target) || !target.bioHolder)
		return

	var/mult = src.get_multiplier(target)
	target.bioHolder.OnLife(mult)
