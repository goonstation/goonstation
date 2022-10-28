/datum/minimap
	///The map render to be displayed.
	var/icon/map_render

	///The z-level that the map is to be rendered from.
	var/z_level = null
	///The maximum x coordinate to be rendered, in world coordinates.
	var/x_max = null
	///The minimum x coordinate to be rendered, in world coordinates.
	var/x_min = null
	///The maximum y coordinate to be rendered, in world coordinates.
	var/y_max = null
	///The minimum y coordinate to be rendered, in world coordinates.
	var/y_min = null

	New()
		. = ..()
		// If the map for the z-level has already been rendered, avoid re-rendering it.
		if (!z_level_maps["[src.z_level]"])
			src.render_map()
			z_level_maps["[src.z_level]"] = src.map_render
		else
			src.map_render = z_level_maps["[src.z_level]"]

	///Renders the map within the boundaries defined by x_max, x_min, y_max, and y_min.
	proc/render_map()
		if (!x_max || !x_min || !y_max || !y_min || !z_level)
			return
		src.map_render = icon('icons/obj/station_map.dmi', "blank")
		for (var/turf/T in block(locate(src.x_min, src.y_min, src.z_level), locate(src.x_max, src.y_max, src.z_level)))
			if (!src.valid_turf(T))
				continue
			map_render.DrawBox(turf_color(T), T.x, T.y)

	///Checks whether a turf should be rendered on the map through the render_on_map variable on /turf.
	proc/valid_turf(var/turf/T)
		if (!T.loc)
			return FALSE
		var/area/A = T.loc
		if (!A.render_on_map)
			return FALSE
		return TRUE

	///Determine the colour of a turf on the map through the station_map_colour variable on /turf.
	proc/turf_color(turf/T)
		if (!T.loc)
			return
		var/area/A = T.loc
		return A.station_map_colour

/datum/minimap/z_level
	z_level = Z_LEVEL_STATION
	x_min = 1
	y_min = 1

	var/icon/initial_map_render

	///The scale that the map should be zoomed to.
	var/zoom_coefficient = 1

	///The offset in the x coordinate caused by zooming the map to the focal point.
	var/zoom_x_offset = 0
	///The offset in the y coordinate caused by zooming the map to the focal point.
	var/zoom_y_offset = 0

	///The x coordinate of the focal point of the map, in world coordinates.
	var/focus_x = null
	///The y coordinate of the focal point of the map, in world coordinates.
	var/focus_y = null

	///The width in pixels between the edge of the station and the edge of the map.
	var/border_width = 20

	New()
		x_max = world.maxx
		y_max = world.maxy

		. = ..()
		initial_map_render = icon(map_render)

		src.find_focal_point()
		src.auto_zoom_map()

	///Locate the focal point of the map by using the furthest valid turf in each direction.
	proc/find_focal_point()
		if (!x_max || !x_min || !y_max || !y_min || !z_level)
			return
		var/max_x = src.x_min
		var/min_x = src.x_max
		var/max_y = src.y_min
		var/min_y = src.y_max
		for (var/turf/T in block(locate(src.x_min, src.y_min, src.z_level), locate(src.x_max, src.y_max, src.z_level)))
			if (!src.valid_turf(T))
				continue
			max_x = max(max_x, T.x)
			min_x = min(min_x, T.x)
			max_y = max(max_y, T.y)
			min_y = min(min_y, T.y)

		var/scale_x = ((max_x - min_x) + border_width) / world.maxx
		var/scale_y = ((max_y - min_y) + border_width) / world.maxy
		src.zoom_coefficient = max(scale_x, scale_y)

		src.focus_x = ((max_x + min_x) - 1) / 2
		src.focus_y = ((max_y + min_y) - 1) / 2

	///Zooms the map by the zoom coefficient.
	proc/auto_zoom_map()
		var/x_amt = x_max * zoom_coefficient
		var/y_amt = y_max * zoom_coefficient

		var/min_x_crop = round(focus_x - (x_amt / 2))
		var/min_y_crop = round(focus_y - (y_amt / 2))
		var/max_x_crop = round(focus_x + (x_amt / 2))
		var/max_y_crop = round(focus_y + (y_amt / 2))

		var/icon/zoomed_map = icon(src.initial_map_render)
		zoomed_map.Crop((min_x_crop), (min_y_crop), (max_x_crop), (max_y_crop))
		zoomed_map.Scale(300, 300)
		src.map_render = zoomed_map

		src.zoom_x_offset = min_x_crop
		src.zoom_y_offset = min_y_crop

/datum/minimap/z_level/ai
	//The Kondaru off-station Owlery and Abandoned Research Outpost are both considered part of the station, but have no AI cameras.
	valid_turf(var/turf/T)
		if (!T.loc)
			return FALSE
		if ((map_settings.name in list("KONDARU", "DONUT3")) && (istype(T.loc, /area/station/garden/owlery) || istype(T.loc, /area/research_outpost/indigo_rye)))
			return FALSE

		. = ..()
