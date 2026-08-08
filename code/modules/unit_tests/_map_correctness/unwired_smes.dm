/datum/map_correctness_check/unwired_smes
	check_name = "SMES Without Cables"

/datum/map_correctness_check/unwired_smes/run_check()
	. = list()

	for_by_tcl(smes, /obj/machinery/power/smes)
		var/smes_ok = FALSE
		for (var/obj/cable/cable in smes.loc)
			if (cable.d1 == 0)
				smes_ok = TRUE
				break

		if (!smes_ok)
			. += CI.format_position(smes)


SET_UP_CI_TRACKING(/obj/machinery/power/smes)
