/datum/map_correctness_check/lightswitchless_areas
	check_name = "Station Areas Without Light Switches"

/datum/map_correctness_check/lightswitchless_areas/run_check()
	. = list()

	var/list/area/station/areas = global.get_accessible_station_areas()
	for (var/area_name in areas)
		var/area/station/A = areas[area_name]

		if (istype(A, /area/station/maintenance))
			continue

		if (!(locate(/obj/machinery/light) in A.machines))
			continue

		if (locate(/obj/machinery/light_switch) in A.machines)
			continue

		. += "[A]"
