/datum/minimap/radar_map

/datum/minimap/radar_map/initialise_minimap_render()
	src.map = new()
	src.map.vis_flags |= VIS_INHERIT_ID
	src.map.mouse_opacity = 0
	src.map.vis_contents += global.minimap_renderer.radar_minimap_objects_by_z_level["[src.z_level]"]

	src.minimap_render = new()
	src.minimap_render.appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	src.minimap_render.mouse_opacity = 0

	src.minimap_render.vis_contents += src.map
	src.minimap_holder.vis_contents += src.minimap_render

/datum/minimap/radar_map/update_z_level(z_level)
	src.map.vis_contents -= global.minimap_renderer.radar_minimap_objects_by_z_level["[src.z_level]"]
	src.z_level = z_level
	src.map.vis_contents += global.minimap_renderer.radar_minimap_objects_by_z_level["[src.z_level]"]
