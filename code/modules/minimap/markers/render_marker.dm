/datum/minimap_marker/render

/datum/minimap_marker/render/New(atom/target)
	. = ..()

	var/icon/marker_icom = icon('icons/obj/minimap/minimap.dmi', "blank")
	if (ismovable(src.target))
		var/atom/movable/AM = src.target
		marker_icom.Scale(round(AM.bound_width / 32, 1), round(AM.bound_height / 32, 1))
	else
		marker_icom.Scale(1, 1)

	marker_icom.SwapColor(rgb(0, 0, 0), hsl2rgb(110, 33, 80))
	src.marker.icon = marker_icom

	src.handle_move(null, null, get_turf(src.target))
	START_TRACKING

/datum/minimap_marker/render/disposing()
	src.handle_move(null, get_turf(src.target), null)
	STOP_TRACKING

	. = ..()

/datum/minimap_marker/render/handle_move(datum/component/component, turf/old_turf, turf/new_turf)
	if (!global.minimap_renderer)
		return

	var/same_z_level = (old_turf?.z == new_turf?.z)

	if (old_turf && global.minimap_renderer.radar_minimap_objects_by_z_level["[old_turf.z]"] && !same_z_level)
		global.minimap_renderer.radar_minimap_objects_by_z_level["[old_turf.z]"].vis_contents -= src.marker

	if (new_turf && global.minimap_renderer.radar_minimap_objects_by_z_level["[new_turf.z]"])
		if (!same_z_level)
			global.minimap_renderer.radar_minimap_objects_by_z_level["[new_turf.z]"].vis_contents += src.marker

		src.marker.pixel_x = new_turf.x - 1
		src.marker.pixel_y = new_turf.y - 1
