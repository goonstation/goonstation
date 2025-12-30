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
	for (var/area/A in world)
		if (A.z != z_level)
			continue
		var/total_gforce = max(A.gforce_minimum, new_gforce + A.gforce_tether)
		for (var/turf/T in A)
			T.gforce_current = round(max(0, total_gforce + T.gforce_inherent), 0.01)

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
		A.set_gforce_minimum(0)

/datum/infooverlay/gravity_turf
	name = "gravity-turf"
	help = {"Colors group mob gravity thresholds. Current (inherent)."}
	var/list/area/processed_areas

	GetInfo(turf/theTurf, image/debugoverlay/img)
		img.app.overlays = list(src.makeText("[theTurf.gforce_current] ([theTurf.gforce_inherent])", RESET_ALPHA | RESET_COLOR))
		switch (theTurf.gforce_current)
			if (-INFINITY to 0)
				img.app.color = "#0000ff"
			if (1)
				img.app.color = "#00ff00"
			if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
				img.app.color = "#00aaaa"
			if (GRAVITY_MOB_REGULAR_THRESHOLD to GRAVITY_MOB_HIGH_THRESHOLD)
				img.app.color = "#009900"
			if (GRAVITY_MOB_HIGH_THRESHOLD to GRAVITY_MOB_EXTREME_THRESHOLD)
				img.app.color = "#cc9900"
			if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
				img.app.color = "#ff0000"

/datum/infooverlay/gravity_area
	name = "gravity-area"
	help = {"Colors tiles based on area gravity only.<br>
	Minimum G-Force + Tether G-Force + Z-level G-Force = Total G-Force"}
	var/list/area/processed_areas

	GetInfo(turf/theTurf, image/debugoverlay/img)
		var/area/A = get_area(theTurf)
		switch (A.gforce_minimum + A.gforce_tether + A.gforce_zlevel)
			if (-INFINITY to 0)
				img.app.color = "#0000ff"
			if (1)
				img.app.color = "#00ff00"
			if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
				img.app.color = "#00aaaa"
			if (GRAVITY_MOB_REGULAR_THRESHOLD to GRAVITY_MOB_HIGH_THRESHOLD)
				img.app.color = "#009900"
			if (GRAVITY_MOB_HIGH_THRESHOLD to GRAVITY_MOB_EXTREME_THRESHOLD)
				img.app.color = "#cc9900"
			if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
				img.app.color = "#ff0000"

		if (A in processed_areas)
			return

		img.app.overlays = list(
			src.makeText("<span style='font-size:6pt'>[A.gforce_minimum]+[A.gforce_tether]+[A.gforce_zlevel]<br>=[A.gforce_minimum + A.gforce_tether + A.gforce_zlevel]</span>")
		)

/datum/infooverlay/grip_view
	name = "grip-view"
	help = "View grip values. Green: grippable; Yellow: not grippable"

	GetInfo(turf/theTurf, image/debugoverlay/img)
		img.app.overlays = list(src.makeText("[theTurf.grip_atom_count]", RESET_ALPHA | RESET_COLOR))
		if (theTurf.grip_atom_count == 0)
			img.app.color = "#990"
			return ..()
		img.app.color = "#0c0"
		return ..()

/datum/infooverlay/grip_debug
	name = "grip-debug"
	help = "Rechecks grip values vs. cache. Red: cache mismatch; Green: grippable; Yellow: not grippable; Actual (cached)"

	GetInfo(turf/theTurf, image/debugoverlay/img)
		var/actual_count = theTurf.calculate_grippy_objects()

		if (theTurf.grip_atom_count != actual_count)
			img.app.overlays = list(src.makeText("[actual_count] ([theTurf.grip_atom_count])", RESET_ALPHA | RESET_COLOR))
			img.app.color = "#f00"
			return ..()
		img.app.overlays = list(src.makeText("[actual_count]", RESET_ALPHA | RESET_COLOR))
		if (actual_count == 0)
			img.app.color = "#990"
			return ..()
		img.app.color = "#0c0"
		return ..()

