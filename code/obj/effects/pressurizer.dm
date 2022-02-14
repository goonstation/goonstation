//It pressurizes areas. - from halloween.dm
/obj/effects/pressurizer
	invisibility = INVIS_ALWAYS_ISH

	New()
		..()
		SPAWN(1 DECI SECOND)
			src.do_pressurize()
			sleep(1 SECOND)
			qdel(src)

	proc/do_pressurize()
		var/turf/simulated/T = src.loc
		if (!istype(T))
			return

		var/datum/gas_mixture/GM = T.return_air()
		if (!istype(GM))
			return

		GM.oxygen *= 1000
		GM.nitrogen *= 1000
		T.process_cell()
