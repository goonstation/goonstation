/datum/component/minimap_marker/render
	var/datum/minimap_marker/render/marker

/datum/component/minimap_marker/render/create_minimap_markers()
	src.marker = new /datum/minimap_marker/render(src.parent)

/datum/component/minimap_marker/render/remove_minimap_markers()
	qdel(src.marker)
	src.marker = null
