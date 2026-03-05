/datum/map_correctness_check/blind_switches
	check_name = "Blind IDs Without Switches"
	check_prefabs = FALSE

/datum/map_correctness_check/blind_switches/run_check()
	. = list()

	// Locate all window blinds.
	var/list/list/blind_IDs = list()
	for_by_tcl(blinds, /obj/window_blinds)
		var/area/A = get_area(blinds)
		var/id = "[blinds.id || A.name]"
		blind_IDs[id] ||= list()
		blind_IDs[id] += blinds

	// Locate all blind switches.
	var/list/list/switch_IDs = list()
	for_by_tcl(blind_switch, /obj/blind_switch)
		var/area/A = get_area(blind_switch)
		var/id = "[blind_switch.id || A.name]"
		switch_IDs[id] ||= list()
		switch_IDs[id] += blind_switch

	var/list/list/lone_IDs = blind_IDs ^ switch_IDs
	for (var/id in lone_IDs)
		for (var/obj/O as anything in lone_IDs[id])
			. += "[src.format_position(O)] has ID \"[id]\", but no associated [istype(O, /obj/window_blinds) ? "switch" : "blinds"]"


SET_UP_CI_TRACKING(/obj/window_blinds)
SET_UP_CI_TRACKING(/obj/blind_switch)
