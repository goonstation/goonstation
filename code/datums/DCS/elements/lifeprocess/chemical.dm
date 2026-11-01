/datum/element/lifeprocess/chemical/process(mob/living/target, datum/gas_mixture/environment)
	if (isdead(target) || target.nodamage)
		return

	var/datum/reagents/reagents = target.reagents
	if (reagents?.total_volume > 0)
		var/mult = src.get_multiplier(target)

		reagents.temperature_reagents(target.bodytemperature, 100 * mult, 100, 15 * mult)

		if (global.blood_system && reagents.get_reagent(target.blood_id))
			var/absorbed_blood = min(
				target.get_blood_absorption_rate() * mult,
				reagents.get_reagent_amount(target.blood_id),
			)

			reagents.remove_reagent(target.blood_id, absorbed_blood)
			target.blood_volume += absorbed_blood

		if (target.metabolizes)
			reagents.metabolize(target, (GET_ATOM_PROPERTY(target, PROP_MOB_METABOLIC_RATE) || 1) * mult)

		if (HAS_ATOM_PROPERTY(target, PROP_MOB_CHEM_PURGE))
			reagents.remove_any(GET_ATOM_PROPERTY(target, PROP_MOB_CHEM_PURGE) * mult)

	if (target.nutrition > target.blood_volume)
		target.nutrition = target.blood_volume

	if (target.nutrition < 0)
		target.contract_disease(/datum/ailment/malady/hypoglycemia, null, null, TRUE)
