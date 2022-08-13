/datum/lifeprocess/radiation
	process(datum/gas_mixture/environment)
		if(!owner || !owner.radiation_dose)
			return

		//apply effects - by this point you have received a non-zero dose, so give the user an infinite duration radiation effect
		//if they haven't got one already
		if(!owner.hasStatus("radiation"))
			owner.changeStatus("radiation",null)

		//remove some rads
		owner.radiation_dose -= src.get_multiplier() * 2 * min(50 * (owner.radiation_dose_decay**2)/(sqrt(2) * sqrt(owner.radiation_dose)), owner.radiation_dose_decay)
		owner.radiation_dose = max(owner.radiation_dose,0)
		..()
