/obj/minimap/admin
	name = "Admin Station Map"
	map_path = /datum/minimap/area_map
	map_type = MAP_ADMINISTRATOR

/obj/minimap/admin/Click(location, control, params)
	USR_ADMIN_ONLY
	var/list/param_list = params2list(params)
	if ("left" in param_list)
		// Convert from screen (x, y) to map (x, y) coordinates.
		var/turf/clicked = src.get_turf_at_screen_coords(text2num(param_list["icon-x"]), text2num(param_list["icon-y"]))
		usr.set_loc(clicked)

	if ("right" in param_list)
		return TRUE
