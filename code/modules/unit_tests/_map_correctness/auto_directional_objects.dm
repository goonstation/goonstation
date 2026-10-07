/datum/map_correctness_check/auto_directional_objects
	check_name = "Undetermined directional object directions"

/datum/map_correctness_check/auto_directional_objects/run_check()
	. = list()

	for_by_tcl(directional, /datum/component/directional)
		var/atom/A = directional.parent
		var/typepath = "[A.type]"
		var/abstract_ending = "/directional"
		if(findtext(typepath, abstract_ending,(length(typepath)-length(abstract_ending))))
			. += CI.format_position(A)
