/datum/map_correctness_check/missing_navbeacons
	check_name = "Missing Navbeacons"

/datum/map_correctness_check/missing_navbeacons/run_check()
	. = list()

	var/list/all_beacons = list()
	for_by_tcl(beacon, /obj/machinery/navbeacon)
		all_beacons[beacon.location] = TRUE

	for_by_tcl(beacon, /obj/machinery/navbeacon)
		for (var/key in list("next_patrol", "next_tour"))
			var/value = beacon.codes[key]
			if (isnull(value))
				continue
			if (!all_beacons[value])
				. += value
