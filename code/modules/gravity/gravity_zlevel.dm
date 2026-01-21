/// Areas on the station Z that are outside the station
///
/// The station gravity tether will not apply to these areas.
var/global/list/z_level_station_outside_area_types = list(
	// areas that are space
	/area/supply,
	/area/mining/magnet, // TODO: This area shouldn't be used on maps :S

	// common near-station areas
	/area/station/turret_protected/armory_outside,
	/area/station/turret_protected/AIbaseoutside,
	/area/station/solar,
	/area/station/catwalk,
	/area/station/com_dish,
	/area/station/shield_zone,
	/area/station/engine/singcore,
	// generally unconnected to station
	/area/station/science/testchamber/bombchamber,
	/area/shuttle/escape/station,
	/area/shuttle/merchant_shuttle/left_station,
	/area/shuttle/merchant_shuttle/right_station,
)

/// Set a minimum gforce across an entire Z-Level e.g. terrainify and oceanify
proc/set_zlevel_gforce(z_level, new_gforce, update_tethers=FALSE)
	global.zlevels[z_level].gforce = new_gforce
	if (update_tethers)
		if (new_gforce == 0)
			SEND_GLOBAL_SIGNAL(COMSIG_GRAVITY_EVENT, GRAVITY_EVENT_CHANGE, z_level, GFORCE_EARTH_GRAVITY) // were going to space vegas, babey
		else if (new_gforce >= GFORCE_EARTH_GRAVITY)
			SEND_GLOBAL_SIGNAL(COMSIG_GRAVITY_EVENT, GRAVITY_EVENT_CHANGE, z_level, 0) // shut off on terrestiral gravity

	for (var/turf/T as anything in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		T.gforce_area_rev = 0

/// Round-start initialization of areas that should have zero minimum gravity
proc/configure_zero_g_areas()
	var/list/area/areas_to_zero = list()

	// Areas on station Z but not conncected to a tether
	for (var/area_typepath in global.z_level_station_outside_area_types)
		areas_to_zero |= get_areas(area_typepath)

	// multi-area tether excluded areas (i.e. listening post comm dish)
	for (var/obj/machinery/gravity_tether/tether as anything in by_cat[TR_CAT_GRAVITY_TETHERS])
		if (istype(tether, /obj/machinery/gravity_tether))
			areas_to_zero |= tether.target_area_refs
			if (istype(tether, /obj/machinery/gravity_tether/multi_area))
				var/obj/machinery/gravity_tether/multi_area/multi_tether = tether
				for (var/area_typepath in multi_tether.base_area_exceptions)
					areas_to_zero |= get_areas(area_typepath)

	// escape shuttle station area
	areas_to_zero |= get_area(global.map_settings.escape_station)

	// shuttle computers (mining, john's bus, research shuttle)
	var/list/shuttle_type_cache = list()
	for (var/obj/machinery/computer/transit_shuttle/shuttle_comp as anything in by_cat[TR_CAT_SHUTTLE_COMPUTERS])
		if (shuttle_comp.type in shuttle_type_cache)
			continue
		for (var/area_typepath in shuttle_comp.destinations)
			areas_to_zero |= get_area_by_type(area_typepath)
		areas_to_zero -= shuttle_comp.currentlocation
		shuttle_type_cache += shuttle_comp.type

	for (var/area/A in areas_to_zero)
		A.set_gforce_minimum(GFORCE_GRAVITY_MINIMUM)
