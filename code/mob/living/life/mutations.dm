
/datum/lifeprocess/mutations
	process(var/datum/gas_mixture/environment)
		//proc/handle_mutations_and_radiation()
		if (owner.bioHolder) owner.bioHolder.OnLife()
		..()