/datum/element/lifeprocess/mutations/process(mob/living/target, mult, datum/gas_mixture/environment)
	if (isdead(target) || !target.bioHolder)
		return

	target.bioHolder.OnLife(mult)
