/datum/component/minimap_marker
	var/minimaps_to_display_on
	var/marker_icon_state
	var/marker_icon
	var/name
	var/list_on_ui

TYPEINFO(/datum/component/minimap_marker)
	initialization_args = list(
		ARG_INFO("minimaps_to_display_on", DATA_INPUT_NUM, "Which minimap types this marker should be displayed on."),
		ARG_INFO("marker_icon_state", DATA_INPUT_TEXT, "The icon which the marker will use.", "pin"),
		ARG_INFO("marker_icon", DATA_INPUT_TEXT, "The .dmi file that the icon for the marker is stored in.", 'icons/obj/minimap/minimap_markers.dmi'),
		ARG_INFO("name", DATA_INPUT_TEXT, "The name of the minimap marker, usually inherited from the target, unless overridden on creation."),
		ARG_INFO("list_on_ui", DATA_INPUT_TEXT, "Whether this minimap marker appears on the controller ui, permitting it's visibility to be toggled, or for it to be deleted.", TRUE)
	)

/datum/component/minimap_marker/Initialize(minimaps_to_display_on, marker_icon_state = "pin", marker_icon = 'icons/obj/minimap/minimap_markers.dmi', name, list_on_ui = TRUE)
	. = ..()
	if(!istype(parent,/atom))
		return COMPONENT_INCOMPATIBLE

	src.minimaps_to_display_on = minimaps_to_display_on
	src.marker_icon_state = marker_icon_state
	src.marker_icon = marker_icon
	src.name = name
	src.list_on_ui = list_on_ui
	src.create_minimap_markers()

	RegisterSignal(parent, COMSIG_NEW_MINIMAP_MARKER, .proc/new_minimap_marker)

/datum/component/minimap_marker/proc/create_minimap_markers()
	if (!minimaps_to_display_on || !marker_icon_state || !marker_icon)
		return

	if (parent in minimap_marker_targets)
		return

	minimap_marker_targets += parent

	// As each minimap may have a differing zoom level and focal point, a unique map marker for each object is required.
	for_by_tcl(minimap, /datum/minimap)
		if (minimap.minimap_type & minimaps_to_display_on)
			minimap.create_minimap_marker(parent, marker_icon, marker_icon_state, name, FALSE, list_on_ui)

/datum/component/minimap_marker/proc/new_minimap_marker(parent, datum/minimap/minimap)
	if (!(minimap.minimap_type & minimaps_to_display_on) || !marker_icon || !marker_icon_state)
		return

	minimap.create_minimap_marker(parent, marker_icon, marker_icon_state, name, FALSE, list_on_ui)

/datum/component/minimap_marker/proc/remove_minimap_markers()
	if (parent in minimap_marker_targets)
		minimap_marker_targets -= parent

		for_by_tcl(minimap, /datum/minimap)
			if (parent in minimap.minimap_markers)
				minimap.remove_minimap_marker(parent)

/datum/component/minimap_marker/UnregisterFromParent()
	src.remove_minimap_markers()
	. = ..()
