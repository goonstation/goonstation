/obj/minimap/alert
	name = "Alert Map"
	map_path = /datum/minimap/area_map/transparent
	map_type = MAP_ALARM
	plane = PLANE_HUD
	layer = HUD_LAYER
	var/obj/machinery/info_map/display = null

	New()
		. = ..()
		src.appearance_flags |= NO_CLIENT_COLOR

	initialise_minimap()
		. = ..()
		src.map.map.plane = src.plane
		src.map.map.layer = src.layer

	Click(location, control, params)
		var/list/param_list = params2list(params)
		if ("left" in param_list)
			var/turf/clicked = src.get_turf_at_screen_coords(text2num(param_list["icon-x"]), text2num(param_list["icon-y"]))
			if (!istype(clicked.loc, /area/space))
				boutput(usr, "This is in the [clicked.loc] area.", "map_area")

	proc/close(mob/user)
		display.UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		user.remove_color_matrix(COLOR_MATRIX_SHADE_LABEL)
		var/datum/hud/hud = user.get_hud()
		hud.remove_object(src)

	disposing()
		src.display = null
		. = ..()

