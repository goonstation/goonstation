/datum/map_correctness_check/stacked_tables
	check_name = "Stacked Tables"

/datum/map_correctness_check/stacked_tables/run_check()
	. = list()

	for_by_tcl(table, /obj/table)
		var/turf/T = table.loc
		for (var/obj/table/other in T)
			if (table == other)
				continue

			. += "([T.x], [T.y], [T.z]) in [global.loaded_prefab_path ? "prefab [global.loaded_prefab_path]" : "[T.loc]"]"
			break
