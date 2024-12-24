/datum/minimap/area_map
	/// A bitflag that determines which areas and minimap markers are to be rendered on the minimap. For available flags, see `_std/defines/minimap.dm`.
	var/minimap_type

	/// A list of minimap render icons, indexed by z-level.
	var/list/icon/map_icons_by_z_level
	/// A list of dynamic area overlay lists, indexed by z-level.
	var/list/list/atom/movable/dynamic_areas_overlays_by_z_level

	/// The scale used to fit all visible turfs on the focused map.
	var/centre_scale
	/// The x coordinate that of the centre of the focused map.
	var/centre_focus_x
	/// The y coordinate that of the centre of the focused map.
	var/centre_focus_y
	/// The width in pixels between the edge of the station and the edge of the map that should be used to determine an ideal centre scale.
	var/border_width = 20

/datum/minimap/area_map/New(scale, minimap_type, marker_scale)
	src.minimap_type = minimap_type

	. = ..()

	if (marker_scale)
		src.marker_scale = marker_scale

	for (var/atom/marker_target as anything in global.minimap_marker_targets)
		SEND_SIGNAL(marker_target, COMSIG_NEW_MINIMAP_MARKER, src)

	src.find_focal_point()

	START_TRACKING

/datum/minimap/disposing()
	STOP_TRACKING
	. = ..()

/datum/minimap/area_map/initialise_minimap_render()
	src.map_icons_by_z_level = global.minimap_renderer.generate_minimap_icons(src.minimap_type)
	src.dynamic_areas_overlays_by_z_level = global.minimap_renderer.get_minimap_dynamic_area_overlays(src.minimap_type)

	src.map = new()
	src.map.icon = src.map_icons_by_z_level["[src.z_level]"]
	src.map.vis_flags |= VIS_INHERIT_ID
	src.map.mouse_opacity = 0
	src.map.vis_contents += src.dynamic_areas_overlays_by_z_level["[src.z_level]"]

	src.minimap_render = new()
	src.minimap_render.appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	src.minimap_render.mouse_opacity = 0

	src.minimap_render.vis_contents += src.map
	src.minimap_holder.vis_contents += src.minimap_render

/datum/minimap/area_map/update_z_level(z_level)
	src.map.vis_contents -= src.dynamic_areas_overlays_by_z_level["[src.z_level]"]

	src.z_level = z_level
	src.map.icon = src.map_icons_by_z_level["[src.z_level]"]
	src.map.vis_contents += src.dynamic_areas_overlays_by_z_level["[src.z_level]"]

	for (var/atom/target as anything in src.minimap_markers)
		var/datum/minimap_marker/minimap/minimap_marker = src.minimap_markers[target]
		src.set_marker_position(minimap_marker, minimap_marker.target.x, minimap_marker.target.y, minimap_marker.target.z)

/// Checks whether a turf is rendered on this minimap type.
/datum/minimap/area_map/proc/valid_turf(turf/T)
	if (!T.loc)
		return FALSE

	var/area/A = T.loc
	if (!(src.minimap_type & A.minimaps_to_render_on))
		return FALSE

	return TRUE

/// Locate the focal point of the map by using the furthest valid turf in each direction.
/datum/minimap/area_map/proc/find_focal_point()
	if (!src.x_max || !src.x_min || !src.y_max || !src.y_min || !src.z_level)
		return

	if (!src.centre_focus_x || !src.centre_focus_y || !src.centre_scale)
		var/max_x = src.x_min
		var/min_x = src.x_max
		var/max_y = src.y_min
		var/min_y = src.y_max

		for (var/turf/T as anything in block(locate(src.x_min, src.y_min, src.z_level), locate(src.x_max, src.y_max, src.z_level)))
			if (!src.valid_turf(T))
				continue

			max_x = max(max_x, T.x)
			min_x = min(min_x, T.x)
			max_y = max(max_y, T.y)
			min_y = min(min_y, T.y)

		src.centre_focus_x = ((max_x + min_x) - 1) / 2
		src.centre_focus_y = ((max_y + min_y) - 1) / 2

		src.centre_scale = min(world.maxx / ((max_x - min_x) + src.border_width), world.maxy / ((max_y - min_y) + src.border_width))

	src.centre_on_point(src.centre_scale, src.centre_focus_x, src.centre_focus_y)

/// Zooms the minimap by the zoom coefficient while moving the minimap so that the specified point lies at the centre of the displayed minimap. The alpha mask takes care of any map area scaled outside of the map boundaries.
/datum/minimap/area_map/proc/centre_on_point(zoom, focus_x, focus_y)
	if (!zoom || (zoom < src.min_zoom) || (zoom > src.max_zoom) || !focus_x || !focus_y)
		return

	var/zoom_factor = (zoom / src.zoom_coefficient)
	src.map.Scale(zoom_factor, zoom_factor)

	// Align the bottom left corner of the scaled map with the bottom left corner of the map boundaries.
	var/x_align_offset = ((src.x_max - (src.x_max * zoom * src.map_scale)) / 2) + src.map.pixel_x
	var/y_align_offset = ((src.y_max - (src.y_max * zoom * src.map_scale)) / 2) + src.map.pixel_y
	src.map.pixel_x -= x_align_offset
	src.map.pixel_y -= y_align_offset
	src.minimap_render.pixel_x += x_align_offset
	src.minimap_render.pixel_y += y_align_offset

	// Offset so that the focal point is at the centre of the map boundaries.
	var/x_offset = ((src.x_max / 2) * src.map_scale) - (focus_x * zoom * src.map_scale) - src.minimap_render.pixel_x
	var/y_offset = ((src.y_max / 2) * src.map_scale) - (focus_y * zoom * src.map_scale) - src.minimap_render.pixel_y
	src.minimap_render.pixel_x += x_offset
	src.minimap_render.pixel_y += y_offset

	src.zoom_coefficient = zoom

	for (var/atom/target as anything in src.minimap_markers)
		var/datum/minimap_marker/minimap/minimap_marker = src.minimap_markers[target]
		src.set_marker_position(minimap_marker, minimap_marker.target.x, minimap_marker.target.y, minimap_marker.target.z)

/datum/minimap/area_map/transparent
	initialise_minimap_render()
		. = ..()
		var/icon/icon = new(src.map.icon)
		icon.SwapColor(rgb(0, 0, 0), rgb(0, 0, 0, 0))
		src.map.icon = icon
