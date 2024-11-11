ABSTRACT_TYPE(/datum/minimap)
/**
 *	Minimap datums are responsible for handling the appearance of the minimap. This includes any displayed markers, the zoom level,
 *	and the displayed z-level.
 */
/datum/minimap
	/// The holder for the render of the minimap, allowing for offsets and other effects to be applied to the render without modifying the render itself.
	var/atom/movable/minimap_render_object/minimap_holder
	/// The minimap render to be displayed, containing both the map, dynamic area overlays, and markers.
	var/atom/movable/minimap_render_object/minimap_render
	/// The minimap, without minimap markers. Kept separate for the purpose of scaling the minimap without scaling the markers.
	var/atom/movable/minimap_render_object/map
	/// An associative list of all minimap markers the minimap is currently tracking and displaying, indexed by their target.
	var/list/datum/minimap_marker/minimap/minimap_markers

	/// The z-level that the minimap is to be rendered from.
	var/z_level = Z_LEVEL_STATION
	/// The maximum x coordinate to be rendered, in world coordinates.
	var/x_max = null
	/// The minimum x coordinate to be rendered, in world coordinates.
	var/x_min = null
	/// The maximum y coordinate to be rendered, in world coordinates.
	var/y_max = null
	/// The minimum y coordinate to be rendered, in world coordinates.
	var/y_min = null

	/// The scale that the minimap should be zoomed to; it does not affect the physical size of the minimap, as the alpha mask will take care of any map area scaled outside of the minimap boundaries.
	var/zoom_coefficient = 1
	/// The minimum value which the zoom coefficient should be permitted to zoom to.
	var/min_zoom = 0.95
	/// The maximum value which the zoom coefficient should be permitted to zoom to.
	var/max_zoom = 10

	/// The current scale of the physical map, as a multiple of the original size (300x300px).
	var/map_scale = 1
	/// The desired scale of the minimap markers, as a multiple of the original size (32x32px).
	var/marker_scale = 1

/datum/minimap/New(scale)
	src.x_max ||= world.maxx
	src.x_min ||= 1
	src.y_max ||= world.maxy
	src.y_min ||= 1

	. = ..()

	src.minimap_holder = new
	src.minimap_holder.appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	src.minimap_holder.mouse_opacity = 0

	src.minimap_markers = list()
	src.initialise_minimap_render()
	src.scale_map(scale)

	START_TRACKING

/datum/minimap/disposing()
	STOP_TRACKING
	. = ..()

/// Initialises the raw minimap icons and minimap render.
/datum/minimap/proc/initialise_minimap_render()
	return

/// Updates the displayed z-level.
/datum/minimap/proc/update_z_level(z_level)
	return

/// Create an alpha mask to hide anything outside the bounds of the physical map.
/datum/minimap/proc/create_alpha_mask()
	var/icon/mask_icon = icon('icons/obj/minimap/minimap.dmi', "blank")
	mask_icon.Scale(src.x_max * src.map_scale, src.y_max * src.map_scale)
	var/x_offset = ((src.x_max * src.map_scale) / 2) - 16
	var/y_offset = ((src.y_max * src.map_scale) / 2) - 16
	src.minimap_holder.add_filter("map_cutoff", 1, alpha_mask_filter(x_offset, y_offset, mask_icon))

/// Zooms the minimap by the zoom coefficient while moving the minimap so that the specified point lies at the same position on the displayed minimap as it did prior to the zoom. The alpha mask takes care of any map area scaled outside of the map boundaries.
/datum/minimap/proc/zoom_on_point(zoom, map_x, map_y)
	if (!zoom || (zoom < src.min_zoom) || (zoom > src.max_zoom) || !map_x || !map_y)
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

	// Account for the number of pixels moved due to scaling.
	var/x_offset = ((((src.x_max * src.zoom_coefficient) - (src.x_max * zoom)) * src.map_scale) / 2) * clamp(((src.x_max / 2) - map_x) / (src.x_max / 2), -1, 1)
	var/y_offset = ((((src.y_max * src.zoom_coefficient) - (src.y_max * zoom)) * src.map_scale) / 2) * clamp(((src.y_max / 2) - map_y) / (src.y_max / 2), -1, 1)
	src.minimap_render.pixel_x -= x_offset
	src.minimap_render.pixel_y -= y_offset

	src.zoom_coefficient = zoom

	for (var/atom/target as anything in src.minimap_markers)
		var/datum/minimap_marker/minimap/minimap_marker = src.minimap_markers[target]
		src.set_marker_position(minimap_marker, minimap_marker.target.x, minimap_marker.target.y, minimap_marker.target.z)

/// Scale the map, while retaining the original (x, y) position of the bottom left corner.
/datum/minimap/proc/scale_map(scale)
	if (!scale)
		return

	var/scale_factor = (scale / src.map_scale)
	src.map.Scale(scale_factor, scale_factor)
	src.map.pixel_x += (src.x_max * src.zoom_coefficient * (scale - src.map_scale)) / 2
	src.map.pixel_y += (src.y_max * src.zoom_coefficient * (scale - src.map_scale)) / 2

	src.map_scale = scale
	src.create_alpha_mask()

	for (var/atom/target as anything in src.minimap_markers)
		var/datum/minimap_marker/minimap/minimap_marker = src.minimap_markers[target]
		src.set_marker_position(minimap_marker, minimap_marker.target.x, minimap_marker.target.y, minimap_marker.target.z)

/// Creates a minimap marker from a specified target, icon, and icon state. `marker_name` will override the marker inheriting the target's name.
/datum/minimap/proc/create_minimap_marker(atom/target, icon, icon_state, marker_name, can_be_deleted_by_player = FALSE, list_on_ui = TRUE)
	if (src.minimap_markers[target])
		return

	var/datum/minimap_marker/minimap/marker = new(target, marker_name, can_be_deleted_by_player, list_on_ui, src.marker_scale)
	marker.map = src
	marker.marker.icon = icon(icon, icon_state)

	src.minimap_markers[target] = marker

	src.minimap_render.vis_contents += marker.marker
	src.set_marker_position(marker, target.x, target.y, target.z)

/// Sets the x and y position of a specified minimap marker, in world coordinates.
/datum/minimap/proc/set_marker_position(datum/minimap_marker/minimap/map_marker, x, y, z)
	if (z != src.z_level)
		map_marker.marker.alpha = 0
		map_marker.on_minimap_z_level = FALSE
	else
		if (map_marker.visible)
			map_marker.marker.alpha = map_marker.alpha_value
		map_marker.on_minimap_z_level = TRUE
		map_marker.marker.pixel_x = (x * src.zoom_coefficient * src.map_scale) - 16
		map_marker.marker.pixel_y = (y * src.zoom_coefficient * src.map_scale) - 16

/// Removes a minimap marker from this minimap.
/datum/minimap/proc/remove_minimap_marker(atom/target)
	if (!src.minimap_markers[target])
		return

	var/datum/minimap_marker/minimap/marker = src.minimap_markers[target]
	src.minimap_render.vis_contents -= marker.marker
	src.minimap_markers -= target
	qdel(marker)


/// Just a helper type to ensure all minimap render parts have the correct vis_flags set
/atom/movable/minimap_render_object
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE


#ifndef LIVE_SERVER
/client/verb/save_station_map()
	if (!global.minimap_renderer)
		CRASH("The minimap renderer has not yet been instatiated.")

	var/datum/minimap/map = new(MAP_ALL)
	src << ftp(map.map.icon, "[map_settings.display_name].png")
#endif
