/**
 *	Minimap controllers are responsible for handling player manipulation of minimaps, including panning and zooming the map,
 *	managing minimap marker visibility, and creating and deleting markers.
 */
/obj/minimap_controller
	name = "Map Controller"
	layer = TURF_LAYER
	anchored = ANCHORED

	/// The controlled minimap object.
	var/obj/minimap/controlled_minimap
	/// The minimap to be displayed, mostly identical to the controlled minimap with the exception that the scale will always be 1. Used to circumvent a bug.
	var/datum/minimap/displayed_minimap

	/// Whether the next click will sample coordinates at the clicked point.
	var/selecting_coordinates = FALSE
	/// A semi-transparent minimap marker used to communicate where the marker will be placed on the minimap.
	var/datum/minimap_marker/minimap/marker_silhouette
	/// The icon that the marker silouette should use.
	var/selected_icon = "pin"
	/// The sampled x coordinate.
	var/selected_x = 1
	/// The sampled y coordinate.
	var/selected_y = 1

	/// The "starting" x position of the drag/pan, allowing for distance moved in the x axis to be calculated and applied to the minimap.
	var/start_click_pos_x = null
	/// The "starting" y position of the drag/pan, allowing for distance moved in the y axis to be calculated and applied to the minimap.
	var/start_click_pos_y = null

/obj/minimap_controller/New(obj/minimap/minimap)
	if (!minimap)
		return

	. = ..()

	src.controlled_minimap = minimap
	START_TRACKING

	if (global.current_state > GAME_STATE_WORLD_NEW)
		src.initialise_minimap_controller()

/obj/minimap_controller/disposing()
	STOP_TRACKING
	. = ..()

/obj/minimap_controller/MouseWheel(dx, dy, loc, ctrl, params)
	. = TRUE
	var/list/param_list = params2list(params)

	// Convert from screen (x, y) to map (x, y) coordinates.
	var/x = round((text2num(param_list["icon-x"]) - src.displayed_minimap.minimap_render.pixel_x) / (src.displayed_minimap.zoom_coefficient * src.displayed_minimap.map_scale))
	var/y = round((text2num(param_list["icon-y"]) - src.displayed_minimap.minimap_render.pixel_y) / (src.displayed_minimap.zoom_coefficient * src.displayed_minimap.map_scale))

	if (dy > 1)
		src.displayed_minimap.zoom_on_point(src.displayed_minimap.zoom_coefficient * 1.1, x, y)
		src.controlled_minimap.map.zoom_on_point(src.displayed_minimap.zoom_coefficient, x, y)
	else if (dy < 1)
		src.displayed_minimap.zoom_on_point(src.displayed_minimap.zoom_coefficient * 0.9, x, y)
		src.controlled_minimap.map.zoom_on_point(src.displayed_minimap.zoom_coefficient, x, y)

	src.pan_map(0, 0)

/obj/minimap_controller/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	var/list/param_list = params2list(params)
	var/x = text2num(param_list["icon-x"])
	var/y = text2num(param_list["icon-y"])

	src.pan_map(x - src.start_click_pos_x, y - src.start_click_pos_y)
	src.start_click_pos_x = x
	src.start_click_pos_y = y

/obj/minimap_controller/MouseDown(location, control, params)
	var/list/param_list = params2list(params)
	src.start_click_pos_x = text2num(param_list["icon-x"])
	src.start_click_pos_y = text2num(param_list["icon-y"])

/obj/minimap_controller/Click(location, control, params)
	if (!src.selecting_coordinates)
		return

	// Convert from screen (x, y) to map (x, y) coordinates, and save to selected x, y vars.
	var/list/param_list = params2list(params)
	src.selected_x = round((text2num(param_list["icon-x"]) - src.displayed_minimap.minimap_render.pixel_x) / (src.displayed_minimap.zoom_coefficient * src.displayed_minimap.map_scale))
	src.selected_y = round((text2num(param_list["icon-y"]) - src.displayed_minimap.minimap_render.pixel_y) / (src.displayed_minimap.zoom_coefficient * src.displayed_minimap.map_scale))

	src.selecting_coordinates = FALSE

/obj/minimap_controller/MouseMove(location, control, params)
	if (!src.selecting_coordinates)
		return

	// Convert from screen (x, y) to map (x, y) coordinates.
	var/list/param_list = params2list(params)
	var/x = round((text2num(param_list["icon-x"]) - src.displayed_minimap.minimap_render.pixel_x) / (src.displayed_minimap.zoom_coefficient * src.displayed_minimap.map_scale))
	var/y = round((text2num(param_list["icon-y"]) - src.displayed_minimap.minimap_render.pixel_y) / (src.displayed_minimap.zoom_coefficient * src.displayed_minimap.map_scale))
	var/turf/map_location = locate(x, y, src.displayed_minimap.z_level)

	if (!src.marker_silhouette)
		src.displayed_minimap.create_minimap_marker(map_location, 'icons/obj/minimap/minimap_markers.dmi', src.selected_icon)
		src.marker_silhouette = src.displayed_minimap.minimap_markers[map_location]
		src.marker_silhouette.alpha_value = 175
		src.marker_silhouette.marker.alpha = 175

	src.marker_silhouette.target = map_location
	src.displayed_minimap.set_marker_position(src.marker_silhouette, src.marker_silhouette.target.x, src.marker_silhouette.target.y, src.displayed_minimap.z_level)

/// Set up this minimap controller's displayed minimap datum and click overlay.
/obj/minimap_controller/proc/initialise_minimap_controller()
	src.displayed_minimap = new src.controlled_minimap.map_path(1, src.controlled_minimap.map_type, (1 / src.controlled_minimap.map_scale))
	src.vis_contents += src.displayed_minimap.minimap_render

	// As the minimap render is transparent to clicks, the minimap will require an overlay which clicks may register on.
	if (!src.icon || !src.icon_state)
		var/icon/click_overlay_icon = icon('icons/obj/minimap/minimap.dmi', "blank")
		click_overlay_icon.Scale(src.displayed_minimap.x_max, src.displayed_minimap.y_max)
		click_overlay_icon.ChangeOpacity(0)
		src.icon = click_overlay_icon
		src.mouse_opacity = 2

/// Pans the minimap by a specified number of pixels.
/obj/minimap_controller/proc/pan_map(x, y)
	src.displayed_minimap.minimap_render.pixel_x += x
	src.displayed_minimap.minimap_render.pixel_y += y

	src.controlled_minimap.map.minimap_render.pixel_x = (src.displayed_minimap.minimap_render.pixel_x - 8) * src.controlled_minimap.map_scale
	src.controlled_minimap.map.minimap_render.pixel_y = (src.displayed_minimap.minimap_render.pixel_y - 8) * src.controlled_minimap.map_scale

/// Resets the minimap to the defaut offset and zoom.
/obj/minimap_controller/proc/reset_scale()
	if (!istype(src.controlled_minimap.map, /datum/minimap/area_map))
		return

	var/datum/minimap/area_map/controlled_minimap = src.controlled_minimap.map
	controlled_minimap.find_focal_point()

	var/datum/minimap/area_map/displayed_minimap = src.displayed_minimap
	displayed_minimap.find_focal_point()

/// Toggles the visibility of all minimap markers.
/obj/minimap_controller/proc/toggle_visibility_all(visible)
	for (var/atom/target as anything in src.controlled_minimap.map.minimap_markers)
		if (target.z != src.controlled_minimap.map.z_level)
			continue

		var/datum/minimap_marker/minimap/marker_cm = src.controlled_minimap.map.minimap_markers[target]
		var/datum/minimap_marker/minimap/marker_dm = src.displayed_minimap.minimap_markers[target]
		if (!visible)
			marker_cm.marker.alpha = 0
			marker_cm.visible = FALSE
			marker_dm.marker.alpha = 0
			marker_dm.visible = FALSE
		else
			marker_cm.marker.alpha = marker_cm.alpha_value
			marker_cm.visible = TRUE
			marker_dm.marker.alpha = marker_dm.alpha_value
			marker_dm.visible = TRUE

/// Toggles the visibility of a specified minimap marker.
/obj/minimap_controller/proc/toggle_visibility(datum/minimap_marker/minimap/marker_cm)
	var/datum/minimap_marker/minimap/marker_dm = src.displayed_minimap.minimap_markers[marker_cm.target]
	if (marker_dm.marker.alpha == marker_dm.alpha_value)
		marker_cm.marker.alpha = 0
		marker_cm.visible = FALSE
		marker_dm.marker.alpha = 0
		marker_dm.visible = FALSE
	else
		marker_cm.marker.alpha = marker_cm.alpha_value
		marker_cm.visible = TRUE
		marker_dm.marker.alpha = marker_dm.alpha_value
		marker_dm.visible = TRUE

/// Creates a new minimap marker and displays it on the minimap.
/obj/minimap_controller/proc/new_marker(location, icon_state, name)
	src.displayed_minimap.create_minimap_marker(location, 'icons/obj/minimap/minimap_markers.dmi', icon_state, name, TRUE)
	src.controlled_minimap.map.create_minimap_marker(location, 'icons/obj/minimap/minimap_markers.dmi', icon_state, name, TRUE)

/// Deletes a minimap marker and removes it on the minimap.
/obj/minimap_controller/proc/delete_marker(datum/minimap_marker/marker)
	src.displayed_minimap.remove_minimap_marker(marker.target)
	src.controlled_minimap.map.remove_minimap_marker(marker.target)
