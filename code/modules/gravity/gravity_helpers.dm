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

/// Remove gravity for areas with tethers at roundstart
proc/initialize_area_gravity()
	var/list/area/areas_to_zero = list()

	// Areas with gravity tethers at roundstart rely on them
	for (var/area/A in world)
		if (length(A.registered_tethers) > 0)
			areas_to_zero |= A

	// Areas on station Z but not conncected to a tether
	for (var/area_typepath in global.z_level_station_outside_area_types)
		areas_to_zero |= get_areas(area_typepath)

	// multi-area tether excluded areas (i.e. listening post comm dish)
	for (var/obj/machinery/gravity_tether/tether as anything in by_cat[TR_CAT_GRAVITY_TETHERS])
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
		A.gforce_minimum = 0 // set directly to avoid wasted gravity recalc
		A.set_turf_gravity(A.gforce_tether) // need to force updates for 0 turf oofies

proc/set_zlevel_gforce(z_level, gforce, update_tethers=FALSE)
	global.zlevels[z_level].gforce = gforce
	if (update_tethers)
		SEND_GLOBAL_SIGNAL(COMSIG_GRAVITY_DISTURBANCE)
		for (var/obj/machinery/gravity_tether/tether as anything in by_cat[TR_CAT_GRAVITY_TETHERS])
			if (tether.z == z_level)
				tether.say("Major gravity shift detected.")
				SPAWN(rand(3,5) SECONDS)
					tether.begin_gravity_change(gforce ? 0 : 1)
	for (var/turf/T in world)
		if (T.z == z_level)
			T.reset_gravity()


/datum/infooverlay/gravity_area
	name = "gravity area"
	help = {"Colors group mob gravity thresholds. Number is gforce, parenthesis is base gravity."}

	GetInfo(turf/theTurf, image/debugoverlay/img)
		var/area/A = get_area(theTurf)

		img.app.overlays = list(src.makeText("[A.gforce_minimum] ([A.gforce_tether])", RESET_ALPHA | RESET_COLOR))
		switch(A.gforce_minimum + A.gforce_tether)
			if (-INFINITY to 0)
				img.app.color = "#0000ff"
			if (1)
				img.app.color = "#00ff00"
			if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
				img.app.color = "#0fffff"
			if (GRAVITY_MOB_REGULAR_THRESHOLD to GRAVITY_MOB_HIGH_THRESHOLD)
				img.app.color = "#009900"
			if (GRAVITY_MOB_HIGH_THRESHOLD to GRAVITY_MOB_EXTREME_THRESHOLD)
				img.app.color = "#ffff00"
			if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
				img.app.color = "#ff0000"

/datum/infooverlay/gravity_turf
	name = "gravity turf"
	help = {"Colors group mob gravity thresholds. Number is the current G-force."}

	GetInfo(turf/theTurf, image/debugoverlay/img)
		img.app.overlays = list(src.makeText("[theTurf.effective_gforce]", RESET_ALPHA | RESET_COLOR))
		switch(theTurf.effective_gforce)
			if (-INFINITY to 0)
				img.app.color = "#0000ff"
			if (1)
				img.app.color = "#00ff00"
			if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
				img.app.color = "#0fffff"
			if (GRAVITY_MOB_REGULAR_THRESHOLD to GRAVITY_MOB_HIGH_THRESHOLD)
				img.app.color = "#009900"
			if (GRAVITY_MOB_HIGH_THRESHOLD to GRAVITY_MOB_EXTREME_THRESHOLD)
				img.app.color = "#ffff00"
			if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
				img.app.color = "#ff0000"

// TODO: this should work like gangtag overlay since it's by area
/datum/infooverlay/gravity_tethers
	name = "gravity tethers"
	help = "show what tethers are affecting areas"

	GetInfo(turf/theTurf, image/debugoverlay/img)
		var/area/A = get_area(theTurf)
		img.app.desc = "Area: [A.name] ([length(A.registered_tethers)] Tethers)"

		var/color_line = ""
		for (var/obj/machinery/gravity_tether/tether in A.registered_tethers)
			img.app.desc += "<br>[tether.name] @ ([tether.x], [tether.y], [tether.z])"
			color_line += "[tether.x][tether.y][tether.z]"
		img.app.color = debug_color_of(color_line)
