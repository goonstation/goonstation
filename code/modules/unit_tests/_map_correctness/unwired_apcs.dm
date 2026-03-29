/datum/map_correctness_check/unwired_apcs
	check_name = "APCs Without Cables"

/datum/map_correctness_check/unwired_apcs/run_check()
	. = list()

	for_by_tcl(apc, /obj/machinery/power/apc)
		var/apc_ok = FALSE
		for (var/obj/cable/cable in apc.loc)
			if (cable.d1 == 0)
				apc_ok = TRUE
				break

		if (!apc_ok)
			. += src.format_position(apc)
