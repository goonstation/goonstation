/datum/component/minimap_marker

/datum/component/minimap_marker/Initialize()
	. = ..()

	if (!isatom(src.parent))
		return COMPONENT_INCOMPATIBLE

	src.create_minimap_markers()

/datum/component/minimap_marker/UnregisterFromParent()
	src.remove_minimap_markers()

	. = ..()

/datum/component/minimap_marker/proc/create_minimap_markers()
	return

/datum/component/minimap_marker/proc/remove_minimap_markers()
	return
