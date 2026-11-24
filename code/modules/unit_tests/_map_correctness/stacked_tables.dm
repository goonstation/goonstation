/datum/map_correctness_check/stacked_tables
	check_name = "Stacked Tables"

/datum/map_correctness_check/stacked_tables/run_check()
	. = list()

	for_by_tcl(table, /obj/table)
		var/turf/T = table.loc
		for (var/obj/table/other in T)
			if (table == other)
				continue

			. += CI.format_location(T)
			break
