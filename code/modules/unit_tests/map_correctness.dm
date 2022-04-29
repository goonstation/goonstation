/// Not quite a unit test but achieves the same goal. Ran for each map unlike actual unit tests.

#ifdef RUNTIME_CHECKING

proc/check_map_correctness()
	check_missing_navbeacons()

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


#endif
