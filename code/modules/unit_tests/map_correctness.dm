/// Not quite a unit test but achieves the same goal. Ran for each map unlike actual unit tests.

// #ifdef RUNTIME_CHECKING

proc/check_map_correctness()
	check_missing_navbeacons()
	check_apcs_wired()
	check_objects_in_walls()

proc/check_missing_navbeacons()
	var/list/all_beacons = list()
	for_by_tcl(beacon, /obj/machinery/navbeacon)
		all_beacons[beacon.location] = TRUE
	var/list/missing = list()
	for_by_tcl(beacon, /obj/machinery/navbeacon)
		for(var/key in list("next_patrol", "next_tour"))
			var/value = beacon.codes[key]
			if(isnull(value))
				continue
			if(!all_beacons[value])
				missing[value] = TRUE
	if(length(missing))
		var/missing_text = jointext(missing, ", ")
		CRASH("Missing navbeacons: " + missing_text)

proc/check_apcs_wired()
	var/list/problematic_areas = list()
	for_by_tcl(apc, /obj/machinery/power/apc)
		var/apc_ok = FALSE
		for(var/obj/cable/cable in apc.loc)
			if(cable.d1 == 0)
				apc_ok = TRUE
				break
		if(!apc_ok)
			problematic_areas += apc.area.name
	if(length(problematic_areas))
		var/problematic_areas_text = jointext(problematic_areas, ", ")
		CRASH("APCs without cables: " + problematic_areas_text)

proc/check_objects_in_walls()
	var/list/log_lines = list()
	for(var/obj/O in world)
		var/turf/T = O.loc
		if(!O.anchored && istype(T) && T?.density)
			log_lines += "[O] [O.type] on [T.x], [T.y], [T.z]) in [T.loc]"
	if(length(log_lines))
		CRASH("Unanchored objects in walls:\n" + jointext(log_lines, "\n"))


// #endif
