/datum/component/minimap_marker
	var/minimaps_to_display_on
	var/marker_icon_state
	var/marker_icon

TYPEINFO(/datum/component/minimap_marker)
	initialization_args = list(
		ARG_INFO("minimaps_to_display_on", DATA_INPUT_NUM, "Which minimap types this marker should be displayed on."),
		ARG_INFO("marker_icon_state", DATA_INPUT_TEXT, "The icon which the marker will use.", "pin"),
		ARG_INFO("marker_icon", DATA_INPUT_TEXT, "The .dmi file that the icon for the marker is stored in.", 'icons/obj/minimap/minimap_markers.dmi')
	)

/datum/component/minimap_marker/Initialize(minimaps_to_display_on, marker_icon_state = "pin", marker_icon = 'icons/obj/minimap/minimap_markers.dmi')
	. = ..()
	src.minimaps_to_display_on = minimaps_to_display_on
	src.marker_icon_state = marker_icon_state
	src.marker_icon = marker_icon

	RegisterSignal(parent, COMSIG_CREATE_MINIMAP_MARKERS, .proc/create_minimap_markers)
	RegisterSignal(parent, COMSIG_NEW_MINIMAP_MARKER, .proc/new_minimap_marker)
	RegisterSignal(parent, COMSIG_REMOVE_MINIMAP_MARKERS, .proc/remove_minimap_markers)

/datum/component/minimap_marker/proc/create_minimap_markers()
	if (!minimaps_to_display_on || !marker_icon_state || !marker_icon)
		return

	if (parent in minimap_marker_targets)
		return

	minimap_marker_targets += parent

	// As each minimap may have a differing zoom level and focal point, a unique map marker for each object is required.
	for_by_tcl(minimap, /obj/minimap)
		if ((minimap.map_type & minimaps_to_display_on) && minimap.map)
			minimap.map.create_minimap_marker(parent, marker_icon, marker_icon_state)

/datum/component/minimap_marker/proc/new_minimap_marker(parent, obj/minimap/minimap)
	if (!(minimap.map_type & minimaps_to_display_on) || !marker_icon || !marker_icon_state)
		return

	minimap.map.create_minimap_marker(parent, marker_icon, marker_icon_state)

/datum/component/minimap_marker/proc/remove_minimap_markers()
	if (parent in minimap_marker_targets)
		minimap_marker_targets -= parent

		for_by_tcl(minimap, /obj/minimap)
			if (minimap.map && (parent in minimap.map.minimap_markers))
				minimap.map.remove_minimap_marker(parent)

/datum/component/minimap_marker/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CREATE_MINIMAP_MARKERS)
	UnregisterSignal(parent, COMSIG_NEW_MINIMAP_MARKER)
	UnregisterSignal(parent, COMSIG_REMOVE_MINIMAP_MARKERS)
	. = ..()
