/datum/component/minimap_marker/minimap
	var/minimaps_to_display_on
	var/marker_icon_state
	var/marker_icon
	var/name
	var/list_on_ui

TYPEINFO(/datum/component/minimap_marker/minimap)
	initialization_args = list(
		ARG_INFO("minimaps_to_display_on", DATA_INPUT_NUM, "Which minimap types this marker should be displayed on."),
		ARG_INFO("marker_icon_state", DATA_INPUT_TEXT, "The icon which the marker will use.", "pin"),
		ARG_INFO("marker_icon", DATA_INPUT_TEXT, "The .dmi file that the icon for the marker is stored in.", 'icons/obj/minimap/minimap_markers.dmi'),
		ARG_INFO("name", DATA_INPUT_TEXT, "The name of the minimap marker, usually inherited from the target, unless overridden on creation."),
		ARG_INFO("list_on_ui", DATA_INPUT_TEXT, "Whether this minimap marker appears on the controller ui, permitting it's visibility to be toggled, or for it to be deleted.", TRUE)
	)

/datum/component/minimap_marker/minimap/Initialize(minimaps_to_display_on, marker_icon_state = "pin", marker_icon = 'icons/obj/minimap/minimap_markers.dmi', name, list_on_ui = TRUE)
	src.minimaps_to_display_on = minimaps_to_display_on
	src.marker_icon_state = marker_icon_state
	src.marker_icon = marker_icon
	src.name = name
	src.list_on_ui = list_on_ui

	. = ..()

	if (!isatom(src.parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_NEW_MINIMAP_MARKER, PROC_REF(new_minimap_marker))

/datum/component/minimap_marker/minimap/create_minimap_markers()
	if (global.minimap_marker_targets[src.parent] || !src.minimaps_to_display_on || !src.marker_icon_state || !src.marker_icon)
		return

	global.minimap_marker_targets[src.parent] = TRUE

	// As each minimap may have a differing zoom level and focal point, a unique map marker for each object is required.
	for_by_tcl(minimap, /datum/minimap/area_map)
		if (minimap.minimap_type & minimaps_to_display_on)
			minimap.create_minimap_marker(src.parent, src.marker_icon, src.marker_icon_state, src.name, FALSE, src.list_on_ui)

/datum/component/minimap_marker/minimap/remove_minimap_markers()
	if (!global.minimap_marker_targets[src.parent])
		return

	global.minimap_marker_targets -= src.parent

	for_by_tcl(minimap, /datum/minimap/area_map)
		if (src.parent in minimap.minimap_markers)
			minimap.remove_minimap_marker(src.parent)

/datum/component/minimap_marker/minimap/proc/new_minimap_marker(parent, datum/minimap/area_map/minimap)
	if (!(minimap.minimap_type & src.minimaps_to_display_on) || !src.marker_icon || !src.marker_icon_state)
		return

	minimap.create_minimap_marker(src.parent, src.marker_icon, src.marker_icon_state, src.name, FALSE, src.list_on_ui)
