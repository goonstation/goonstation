/obj/minimap
	name = "Station Map"
	layer = TURF_LAYER
	anchored = TRUE
	var/datum/minimap/map
	var/map_path = /datum/minimap/z_level
	var/map_type = MAP_DEFAULT

	New()
		. = ..()
		START_TRACKING
		map = get_singleton(map_path)
		vis_contents += map.minimap_render

		for (var/atom/movable/marker_object in minimap_marker_targets)
			if (src.map_type & marker_object.minimaps_to_display_on)
				src.map.create_minimap_marker(marker_object.tracked_minimap_marker, marker_object, marker_object.minimap_marker_icon, marker_object.minimap_marker_icon_state)

	disposing()
		STOP_TRACKING
		. = ..()

/obj/minimap/ai
	name = "AI Station Map"
	map_path = /datum/minimap/z_level/ai
	map_type = MAP_AI

	Click(location, control, params)
		if (!isAI(usr))
			return
		var/list/param_list = params2list(params)
		var/datum/minimap/z_level/ai_map = map
		if ("left" in param_list)
			var/x = round((text2num(param_list["icon-x"]) / ai_map.zoom_coefficient) + ai_map.zoom_x_offset)
			var/y = round((text2num(param_list["icon-y"]) / ai_map.zoom_coefficient) + ai_map.zoom_y_offset)
			var/turf/clicked = locate(x, y, map.z_level)
			if (isAIeye(usr))
				usr.set_loc(clicked)
			else
				var/mob/living/silicon/ai/mainframe = usr
				mainframe.eye_view()
				mainframe.eyecam.set_loc(clicked)
		if ("right" in param_list)
			return TRUE
