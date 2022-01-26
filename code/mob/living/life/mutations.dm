
/datum/lifeprocess/mutations
	process(var/datum/gas_mixture/environment)
		if (isdead(owner))
			return ..()
		//proc/handle_mutations_and_radiation()
		if (owner.bioHolder) owner.bioHolder.OnLife(mult = get_multiplier())
		..()
