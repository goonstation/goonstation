/datum/minimap
	///The minimap render to be displayed, containing both the map, and icons.
	var/atom/movable/minimap_render
	///The map, without map markers. Kept separate for the purpose of scaling the map without scaling the markers.
	var/atom/movable/map

	var/map_type

	///The z-level that the minimap is to be rendered from.
	var/z_level = null
	///The maximum x coordinate to be rendered, in world coordinates.
	var/x_max = null
	///The minimum x coordinate to be rendered, in world coordinates.
	var/x_min = null
	///The maximum y coordinate to be rendered, in world coordinates.
	var/y_max = null
	///The minimum y coordinate to be rendered, in world coordinates.
	var/y_min = null

	///An associative list of all the objects and associated minimap markers the minimap is currently tracking and displaying.
	var/list/minimap_markers = list()

	///The scale that the minimap should be zoomed to.
	var/zoom_coefficient = 1

	// All of the below are required for map marker calculations, but aren't used for anything else in the minimap parent.
	///The current scale of the physical map, as a multiple of the original size.
	var/map_scale = 1

	New(var/map_type)
		. = ..()
		src.minimap_render = new
		src.map = new /atom/movable
		src.map_type = map_type

		// If the map for the z-level has already been rendered, avoid re-rendering it.
		if (!z_level_maps["[src.z_level]-[map_type]"])
			src.render_minimap()
			z_level_maps["[src.z_level]-[map_type]"] = icon(src.map.icon)
		else
			src.map.icon = z_level_maps["[src.z_level]"]

		src.minimap_render.vis_flags = VIS_INHERIT_LAYER
		src.minimap_render.appearance_flags = KEEP_TOGETHER
		src.minimap_render.mouse_opacity = 0
		src.map.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
		src.map.mouse_opacity = 0

		src.minimap_render.vis_contents += src.map

	///Renders the map within the boundaries defined by x_max, x_min, y_max, and y_min.
	proc/render_minimap()
		if (!x_max || !x_min || !y_max || !y_min || !z_level)
			return
		var/icon/map = icon('icons/obj/minimap/minimap.dmi', "blank")
		for (var/turf/T in block(locate(src.x_min, src.y_min, src.z_level), locate(src.x_max, src.y_max, src.z_level)))
			if (!src.valid_turf(T))
				continue
			map.DrawBox(turf_color(T), T.x, T.y)
		src.map.icon = icon(map)

	///Checks whether a turf should be rendered on the map through the render_on_map variable on /turf.
	proc/valid_turf(var/turf/T)
		if (!T.loc)
			return FALSE
		var/area/A = T.loc
		if (!(src.map_type & A.minimaps_to_render_on) && !(A.minimaps_to_render_on & MAP_ALL))
			return FALSE
		return TRUE

	///Determine the colour of a turf on the map through the station_map_colour variable on /turf.
	proc/turf_color(turf/T)
		if (!T.loc)
			return
		var/area/A = T.loc
		return A.station_map_colour

	///Create an alpha mask to hide anything outside the bounds of the physical map.
	proc/create_alpha_mask()
		var/icon/mask_icon = icon('icons/obj/minimap/minimap.dmi', "blank")
		mask_icon.Scale(300 * src.map_scale, 300 * src.map_scale)
		var/offset = ((300 * src.map_scale) / 2) - 16
		src.minimap_render.add_filter("map_cutoff", 1, alpha_mask_filter(offset, offset, mask_icon))

	///Creates a minimap marker from a specified target, icon, and icon state.
	proc/create_minimap_marker(var/atom/target, var/icon, var/icon_state, var/marker_name, var/can_be_deleted_by_player)
		if (target in src.minimap_markers)
			return

		var/datum/minimap_marker/marker = new /datum/minimap_marker(target, marker_name, can_be_deleted_by_player)
		marker.map = src
		marker.marker.icon = icon(icon, icon_state)

		src.minimap_markers[target] = marker

		src.minimap_render.vis_contents += marker.marker
		src.set_marker_position(marker, target.x, target.y, target.z)

	///Sets the x and y position of a specified minimap marker, in world coordinates.
	proc/set_marker_position(var/datum/minimap_marker/map_marker, var/x, var/y, var/z)
		if (z != src.z_level)
			map_marker.marker.alpha = 0
			map_marker.visible = FALSE
			map_marker.on_minimap_z_level = FALSE
		else
			if (map_marker.visible == TRUE)
				map_marker.marker.alpha = 255
			map_marker.on_minimap_z_level = TRUE
			map_marker.marker.pixel_x = (x * src.zoom_coefficient * src.map_scale) - 16
			map_marker.marker.pixel_y = (y * src.zoom_coefficient * src.map_scale) - 16

	proc/remove_minimap_marker(var/atom/target)
		if (!(target in src.minimap_markers))
			return

		var/datum/minimap_marker/marker = src.minimap_markers[target]
		src.minimap_render.vis_contents -= marker.marker
		src.minimap_markers -= target
		qdel(marker)

/datum/minimap/z_level
	z_level = Z_LEVEL_STATION
	x_min = 1
	y_min = 1

	var/icon/initial_minimap_icon

	///The width in pixels between the edge of the station and the edge of the map.
	var/border_width = 20

	New(var/map_type, var/scale)
		x_max = world.maxx
		y_max = world.maxy

		. = ..()
		src.initial_minimap_icon = src.map.icon

		if (scale)
			src.scale_map(scale)

		src.find_focal_point()

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

		var/focus_x = ((max_x + min_x) - 1) / 2
		var/focus_y = ((max_y + min_y) - 1) / 2

		var/scale_x = world.maxx / ((max_x - min_x) + border_width)
		var/scale_y = world.maxy / ((max_y - min_y) + border_width)

		src.centre_on_point(min(scale_x, scale_y), focus_x, focus_y)

	///Zooms the minimap by the zoom coefficient while moving the minimap so that the specified point lies at the same position on the displayed minimap as it did prior to the zoom. The alpha mask takes care of any map area scaled outside of the map boundaries.
	proc/zoom_on_point(var/zoom, var/map_x, var/map_y)
		if (!zoom || zoom == 0 || !map_x || !map_y)
			return

		var/zoom_factor = (zoom / src.zoom_coefficient)
		src.map.Scale(zoom_factor, zoom_factor)

		// Align the bottom left corner of the scaled map with the bottom left corner of the map boundaries.
		var/x_align_offset = ((300 - (300 * zoom * src.map_scale)) / 2) + src.map.pixel_x
		var/y_align_offset = ((300 - (300 * zoom * src.map_scale)) / 2) + src.map.pixel_y
		src.map.pixel_x -= x_align_offset
		src.map.pixel_y -= y_align_offset
		src.minimap_render.pixel_x += x_align_offset
		src.minimap_render.pixel_y += y_align_offset

		// Account for the number of pixels moved due to scaling.
		var/x_offset = ((((300 * src.zoom_coefficient) - (300 * zoom)) * src.map_scale) / 2) * clamp((150 - map_x) / 150, -1, 1)
		var/y_offset = ((((300 * src.zoom_coefficient) - (300 * zoom)) * src.map_scale) / 2) * clamp((150 - map_y) / 150, -1, 1)
		src.minimap_render.pixel_x -= x_offset
		src.minimap_render.pixel_y -= y_offset

		// Reset the alpha mask's position to the bottom left corner.
		var/filter = src.minimap_render.filters[length(src.minimap_render.filters)]
		filter:x = ((300 * src.map_scale) / 2) - 16 - src.minimap_render.pixel_x
		filter:y = ((300 * src.map_scale) / 2) - 16 - src.minimap_render.pixel_y

		src.zoom_coefficient = zoom

		for (var/atom/target in src.minimap_markers)
			var/datum/minimap_marker/minimap_marker = src.minimap_markers[target]
			src.set_marker_position(minimap_marker, target.x, target.y, target.z)

	///Zooms the minimap by the zoom coefficient while moving the minimap so that the specified point lies at the centre of the displayed minimap. The alpha mask takes care of any map area scaled outside of the map boundaries.
	proc/centre_on_point(var/zoom, var/focus_x, var/focus_y)
		if (!zoom || zoom == 0 || !focus_x || !focus_y)
			return

		var/zoom_factor = (zoom / src.zoom_coefficient)
		src.map.Scale(zoom_factor, zoom_factor)

		// Align the bottom left corner of the scaled map with the bottom left corner of the map boundaries.
		var/x_align_offset = ((300 - (300 * zoom * src.map_scale)) / 2) + src.map.pixel_x
		var/y_align_offset = ((300 - (300 * zoom * src.map_scale)) / 2) + src.map.pixel_y
		src.map.pixel_x -= x_align_offset
		src.map.pixel_y -= y_align_offset
		src.minimap_render.pixel_x += x_align_offset
		src.minimap_render.pixel_y += y_align_offset

		// Offset so that the focal point is at the centre of the map boundaries.
		var/x_offset = (150 * src.map_scale) - (focus_x * zoom * src.map_scale) - src.minimap_render.pixel_x
		var/y_offset = (150 * src.map_scale) - (focus_y * zoom * src.map_scale) - src.minimap_render.pixel_y
		src.minimap_render.pixel_x += x_offset
		src.minimap_render.pixel_y += y_offset

		// Reset the alpha mask's position to the bottom left corner.
		var/filter = src.minimap_render.filters[length(src.minimap_render.filters)]
		filter:x = ((300 * src.map_scale) / 2) - 16 - src.minimap_render.pixel_x
		filter:y = ((300 * src.map_scale) / 2) - 16 - src.minimap_render.pixel_y

		src.zoom_coefficient = zoom

		for (var/atom/target in src.minimap_markers)
			var/datum/minimap_marker/minimap_marker = src.minimap_markers[target]
			src.set_marker_position(minimap_marker, target.x, target.y, target.z)

	///Scale the map, while retaining the original (x, y) position of the bottom left corner.
	proc/scale_map(var/scale)
		if (!scale || scale == 0)
			return

		var/scale_factor = (scale / src.map_scale)
		src.map.Scale(scale_factor, scale_factor)
		src.map.pixel_x += (300 * zoom_coefficient * (scale - src.map_scale)) / 2
		src.map.pixel_y += (300 * zoom_coefficient * (scale - src.map_scale)) / 2

		src.map_scale = scale

		src.create_alpha_mask()

		// Update the position of all the map markers to reflect the new map scale.
		for (var/atom/target in src.minimap_markers)
			var/datum/minimap_marker/minimap_marker = src.minimap_markers[target]
			src.set_marker_position(minimap_marker, target.x, target.y, target.z)

/datum/minimap/z_level/ai
	//The Kondaru off-station Owlery and Abandoned Research Outpost are both considered part of the station, but have no AI cameras.
	valid_turf(var/turf/T)
		if (!T.loc)
			return FALSE
		if ((map_settings.name in list("KONDARU", "DONUT3")) && (istype(T.loc, /area/station/garden/owlery) || istype(T.loc, /area/research_outpost/indigo_rye)))
			return FALSE

		. = ..()
