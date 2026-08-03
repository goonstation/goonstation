/datum/map_correctness_check/stacked_mapping_helpers
	check_name = "Stacked Mapping Helpers"

/datum/map_correctness_check/stacked_mapping_helpers/run_check()
	. = list()

	for_by_tcl(mapping_helper, /obj/mapping_helper)
		var/turf/T = mapping_helper.loc
		for (var/obj/mapping_helper/other in T)
			if ((mapping_helper == other) || (mapping_helper.type != other.type))
				continue

			. += "([T.x], [T.y], [T.z]) in [global.loaded_prefab_path ? "prefab [global.loaded_prefab_path]" : "[T.loc]"]"
			break


SET_UP_CI_TRACKING(/obj/mapping_helper)
