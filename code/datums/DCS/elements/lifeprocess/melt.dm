/datum/element/lifeprocess/melt/process(mob/living/target, mult, datum/gas_mixture/environment)
	if (target.bodytemperature >= (target.base_body_temp + target.temp_tolerance))
		target.TakeDamage("All", 0, 5, 0, DAMAGE_BURN)

	else if (target.bodytemperature <= (target.base_body_temp - target.temp_tolerance))
		target.TakeDamage("All", 0, -5, 0, DAMAGE_BURN)
