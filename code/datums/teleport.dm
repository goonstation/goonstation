var/global/list/teleareas

proc/get_teleareas()
	if (isnull(teleareas))
		generate_teleareas()
	return teleareas

proc/get_telearea(var/name)
	var/list/areas = get_teleareas()
	return areas[name]

proc/generate_teleareas()
	LAGCHECK(LAG_HIGH)
	teleareas = list()
	for (var/area/area in world)
		if (istype(area, /area/station))
			var/turf/T = area.contents[1]
			if (T?.z == Z_LEVEL_STATION)
				teleareas[area.name] = area
		if (istype(area, /area/diner))
			var/turf/T = area.contents[1]
			if (!isrestrictedz(T?.z))
				teleareas[area.name] = area
		if(istype(area, /area/wizard_station))
			teleareas[area.name] = area
	sortList(teleareas, /proc/cmp_text_asc)
