/obj/minimap
	name = "Station Map"
	layer = TURF_LAYER
	anchored = TRUE
	var/datum/minimap/map
	var/map_path = /datum/minimap/z_level

	New()
		. = ..()
		map = new map_path
		icon = map.map_render

	update_icon()
		. = ..()
		icon = map.map_render

/obj/minimap/ai
	name = "AI Station Map"
	map_path = /datum/minimap/z_level/ai

	Click(location, control, params)
		if (!isAI(usr))
			return
		var/list/param_list = params2list(params)
		var/datum/minimap/z_level/ai_map = map
		if ("left" in param_list)
			var/x = round((text2num(param_list["icon-x"]) * ai_map.zoom_coefficient) + ai_map.zoom_x_offset)
			var/y = round((text2num(param_list["icon-y"]) * ai_map.zoom_coefficient) + ai_map.zoom_y_offset)
			var/turf/clicked = locate(x, y, map.z_level)
			if (isAIeye(usr))
				usr.set_loc(clicked)
			else
				var/mob/living/silicon/ai/mainframe = usr
				mainframe.eye_view()
				mainframe.eyecam.set_loc(clicked)
		if ("right" in param_list)
			return TRUE
