
/datum/lifeprocess/chems
	process(var/datum/gas_mixture/environment)
		//proc/handle_chemicals_in_body()
		if (owner.nodamage)
			return ..()

		if (owner.reagents)
			var/reagent_time_multiplier = get_multiplier()

			owner.reagents.temperature_reagents(owner.bodytemperature, 100, 35/reagent_time_multiplier, 15*reagent_time_multiplier)

			if (blood_system && owner.reagents.get_reagent("blood"))
				var/blood2absorb = min(owner.blood_absorption_rate, owner.reagents.get_reagent_amount("blood")) * reagent_time_multiplier
				owner.reagents.remove_reagent("blood", blood2absorb)
				owner.blood_volume += blood2absorb
			if (owner.metabolizes)
				owner.reagents.metabolize(owner, multiplier = reagent_time_multiplier)

		if (owner.nutrition > owner.blood_volume)
			owner.nutrition = owner.blood_volume
		if (owner.nutrition < 0)
			owner.contract_disease(/datum/ailment/malady/hypoglycemia, null, null, 1)

		..()
		//health_update_queue |= src //#843 uncomment this if things go funky maybe

