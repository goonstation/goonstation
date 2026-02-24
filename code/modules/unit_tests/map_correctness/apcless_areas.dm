/datum/map_correctness_check/apcless_areas
	check_name = "Station Areas Without APCs"

/datum/map_correctness_check/apcless_areas/run_check()
	. = list()

	var/list/area/station/areas = global.get_accessible_station_areas()
	for (var/area_name in areas)
		if (!isnull(areas[area_name].area_apc))
			continue

		. += "[area_name]"
