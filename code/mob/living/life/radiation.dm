/datum/lifeprocess/radiation
	var/tick_count = 0
	process(datum/gas_mixture/environment)
		if(!owner || !owner.radiation_dose)
			return

		//apply effects - by this point you have received a non-zero dose, so give the user an infinite duration radiation effect
		//if they haven't got one already
		if(!owner.hasStatus("radiation"))
			owner.changeStatus("radiation",null)

		if(!isdead(owner))
			//remove some rads
			tick_count++
			boutput(world, "T: [tick_count] R: [owner.radiation_dose] D: [(src.get_multiplier() * (owner.radiation_dose_decay * (owner.radiation_dose**1.3))/2)]")
			owner.radiation_dose = max(owner.radiation_dose - (src.get_multiplier() * (owner.radiation_dose_decay * (owner.radiation_dose**1.3))/2),0)
