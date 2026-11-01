/datum/element/lifeprocess/radiation/process(mob/living/target, datum/gas_mixture/environment)
	if (!target.radiation_dose)
		return

	if (!target.hasStatus("radiation"))
		target.changeStatus("radiation", null)

	if (!isdead(target))
		var/mult = src.get_multiplier(target)
		var/decay = (target.radiation_dose_decay * (target.radiation_dose ** 1.2)) * mult
		target.radiation_dose = max(target.radiation_dose - decay, 0)
