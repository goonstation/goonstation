var/global/list/teleareas
var/global/list/nukie_deployment_areas

proc/get_teleareas()
	if (isnull(teleareas))
		generate_teleareas()
	return teleareas

proc/get_nukie_deployment_areas()
	if (isnull(nukie_deployment_areas))
		generate_nukie_deployment_areas()
	return nukie_deployment_areas

proc/get_telearea(var/name)
	var/list/areas = get_teleareas()
	return areas[name]

proc/generate_teleareas() //Turns out nukies could deploy to the wizards den all this time
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

proc/generate_nukie_deployment_areas() //Turns out nukies could deploy to the wizards den all this time
	LAGCHECK(LAG_HIGH)
	nukie_deployment_areas = list()
	for (var/area/area in world)
		if (istype(area, /area/station))
			var/turf/T = area.contents[1]
			if (T?.z == Z_LEVEL_STATION)
				nukie_deployment_areas[area.name] = area
	sortList(nukie_deployment_areas, /proc/cmp_text_asc)
