/obj/minimap
	name = "Station Map"
	layer = TURF_LAYER
	anchored = TRUE
	var/datum/minimap/z_level/map

	New()
		. = ..()
		map = new /datum/minimap/z_level
		icon = map.map_render

	update_icon()
		. = ..()
		icon = map.map_render

/obj/minimap/ai
	name = "AI Station Map"

	Click(location, control, params)
		if (!isAI(usr))
			return
		var/list/param_list = params2list(params)
		if ("left" in param_list)
			var/x = round((text2num(param_list["icon-x"]) * map.zoom_coefficient) + map.zoom_x_offset)
			var/y = round((text2num(param_list["icon-y"]) * map.zoom_coefficient) + map.zoom_y_offset)
			var/turf/clicked = locate(x, y, map.z_level)
			if (isAIeye(usr))
				usr.loc = clicked
			else
				var/mob/living/silicon/ai/mainframe = usr
				mainframe.eye_view()
				mainframe.eyecam.loc = clicked
		if ("right" in param_list)
			return TRUE
