/datum/lifeprocess/radiation
	process(datum/gas_mixture/environment)
		if(!owner || !owner.radiation_dose)
			return

		//apply effects
		owner.changeStatus("radiation",null)

		//remove some rads
		owner.radiation_dose = max(owner.radiation_dose - (src.get_multiplier() * owner.radiation_dose_decay),0)
		..()
