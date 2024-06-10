
/datum/lifeprocess/chems
	process(var/datum/gas_mixture/environment)
		//proc/handle_chemicals_in_body()
		if(isdead(owner))
			return ..()
		if (owner.nodamage)
			return ..()

		if (owner.reagents?.total_volume > 0)
			var/reagent_time_multiplier = get_multiplier()

			owner.reagents.temperature_reagents(owner.bodytemperature, 100*reagent_time_multiplier, 100, 15*reagent_time_multiplier)

			if (blood_system && owner.reagents.get_reagent("[owner.blood_id]"))
				var/blood2absorb = min(owner.get_blood_absorption_rate(), owner.reagents.get_reagent_amount("[owner.blood_id]")) * reagent_time_multiplier
				owner.reagents.remove_reagent("[owner.blood_id]", blood2absorb)
				owner.blood_volume += blood2absorb
			if (owner.metabolizes && owner.reagents)//idk it runtimes)
				owner.reagents.metabolize(owner, multiplier = reagent_time_multiplier * (HAS_ATOM_PROPERTY(owner, PROP_MOB_METABOLIC_RATE) ? GET_ATOM_PROPERTY(owner, PROP_MOB_METABOLIC_RATE) : 1))

			if(HAS_ATOM_PROPERTY(owner, PROP_MOB_CHEM_PURGE))
				owner.reagents.remove_any(GET_ATOM_PROPERTY(owner, PROP_MOB_CHEM_PURGE) * reagent_time_multiplier)


		if (owner.nutrition > owner.blood_volume)
			owner.nutrition = owner.blood_volume
		if (owner.nutrition < 0)
			owner.contract_disease(/datum/ailment/malady/hypoglycemia, null, null, 1)

		..()
		//health_update_queue |= src //#843 uncomment this if things go funky maybe

