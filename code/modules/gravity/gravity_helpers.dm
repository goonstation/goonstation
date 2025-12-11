proc/initialize_area_gravity()
	var/list/area/areas_to_zero = list()

	// Areas with gravity tethers at roundstart rely on them
	for (var/area/A in world)
		if (length(A.registered_tethers) > 0)
			areas_to_zero |= A

	// Areas on station Z but not conncected to a tether are zeroed
	for (var/area_type in global.z_level_station_outside_area_types)
		areas_to_zero |= get_areas(area_type)

	for (var/area/A in areas_to_zero)
		A.base_gravity = 0
		A.update_gravity()

/// Set gravity on all turfs in all areas
proc/recalculate_world_gravity()
	for (var/area/A in world)
		A.update_gravity()

/// Get gforces provided by all station gravity tethers
proc/get_station_gravity()
	. = 0
	for (var/obj/machinery/gravity_tether/tether as anything in by_cat[TR_CAT_GRAVITY_TETHERS])
		if (istype(tether, /obj/machinery/gravity_tether/station))
			if (tether.has_no_power())
				continue
			. += tether.intensity

/datum/infooverlay/gravity
	name = "gravity gforce"
	help = {"Colors group mob gravity thresholds. Number is the current G-force."}

	GetInfo(turf/theTurf, image/debugoverlay/img)
		img.app.overlays = list(src.makeText("[theTurf.effective_gravity]", RESET_ALPHA | RESET_COLOR))
		switch(theTurf.effective_gravity)
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
