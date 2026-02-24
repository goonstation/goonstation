/datum/map_correctness_check/networked_data_terminals
	check_name = "Machinery Without Terminals"

/datum/map_correctness_check/networked_data_terminals/run_check()
	. = list()

	for_by_tcl(networked, /obj/machinery/networked)
		if (locate(/obj/machinery/power/data_terminal) in networked.loc)
			continue

		. += src.format_position(networked)

	for (var/turf/T in global.job_start_locations["AI"])
		if (locate(/obj/machinery/power/data_terminal) in T)
			continue

		. += "AI start landmark at ([T.x], [T.y], [T.z]) in [T.loc]"


SET_UP_CI_TRACKING(/obj/machinery/networked)
