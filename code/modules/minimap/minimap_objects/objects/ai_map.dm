/obj/minimap/ai
	name = "AI Station Map"
	map_path = /datum/minimap/area_map
	map_type = MAP_AI

/obj/minimap/ai/Click(location, control, params)
	if (!isAI(usr))
		return

	var/list/param_list = params2list(params)
	if ("left" in param_list)
		// Convert from screen (x, y) to map (x, y) coordinates.
		var/x = round((text2num(param_list["icon-x"]) - src.map.minimap_render.pixel_x) / (src.map.zoom_coefficient * src.map.map_scale))
		var/y = round((text2num(param_list["icon-y"]) - src.map.minimap_render.pixel_y) / (src.map.zoom_coefficient * src.map.map_scale))
		var/turf/clicked = locate(x, y, map.z_level)
		if (isAIeye(usr))
			usr.set_loc(clicked)
		else
			var/mob/living/silicon/ai/mainframe = usr
			mainframe.eye_view()
			mainframe.eyecam.set_loc(clicked)

	if ("right" in param_list)
		return TRUE
