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
		var/turf/clicked = src.get_turf_at_screen_coords(text2num(param_list["icon-x"]), text2num(param_list["icon-y"]))
		if (isAIeye(usr))
			usr.set_loc(clicked)
		else
			var/mob/living/silicon/ai/mainframe = usr
			mainframe.eye_view()
			mainframe.eyecam.set_loc(clicked)

	if ("right" in param_list)
		return TRUE
