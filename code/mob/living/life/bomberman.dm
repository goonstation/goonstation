
/datum/lifeprocess/bomberman
	process(var/datum/gas_mixture/environment)
		new /obj/bomberman(get_turf(owner))
		..()