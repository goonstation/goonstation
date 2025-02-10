/obj/minimap/observer_minimap
	name = "Station Map"
	map_path = /datum/minimap/area_map
	map_type = MAP_OBSERVER

/obj/minimap/observer_minimap/Click(location, control, params)
	if (!(isobserver(usr) || isadmin(usr)))
		return
	var/list/param_list = params2list(params)
	if ("left" in param_list)
		// Convert from screen (x, y) to map (x, y) coordinates.
		var/turf/clicked = src.get_turf_at_screen_coords(text2num(param_list["icon-x"]), text2num(param_list["icon-y"]))
		usr.set_loc(clicked)
		return
