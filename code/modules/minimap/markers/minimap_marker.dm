/datum/minimap_marker/minimap
	/// The minimap datum that the minimap marker belongs to.
	var/datum/minimap/map

	/// The name of the minimap marker, usually inherited from the target, unless overridden on creation.
	var/name = "Minimap Marker"
	/// Whether the minimap marker is visible, with precedence over alpha settings.
	var/visible = TRUE
	/// The alpha value that the minimap marker should use when visible.
	var/alpha_value = 255
	/// The desired scale of the minimap marker, as a multiple of the original size (32x32px).
	var/marker_scale = 1
	/// Whether the target is on the minimap datum's rendered z-level, determining whether it is displayed.
	var/on_minimap_z_level = FALSE
	/// Whether the minimap marker can be deleted by players using minimap controllers.
	var/can_be_deleted_by_player = FALSE
	/// Whether this minimap marker appears on the controller UI, permitting it's visibility to be toggled, or for it to be deleted.
	var/list_on_ui = TRUE
	/// Marker's icon_state
	var/icon_state = null

/datum/minimap_marker/minimap/disposing()
	// cleanup reference loops
	map = null
	. = ..()

/datum/minimap_marker/minimap/New(atom/target, name, can_be_deleted_by_player = FALSE, list_on_ui = TRUE, marker_scale)
	. = ..()

	src.name = name || src.target.name
	src.can_be_deleted_by_player = can_be_deleted_by_player
	src.list_on_ui = list_on_ui
	src.scale_marker(marker_scale)

/datum/minimap_marker/minimap/handle_move(datum/component/component, turf/old_turf, turf/new_turf)
	. = ..()
	if (!src.map || !new_turf)
		return

	src.map.set_marker_position(src, new_turf.x, new_turf.y, new_turf.z)

/// Scale the minimap marker to a multiple of the original marker size.
/datum/minimap_marker/minimap/proc/scale_marker(scale)
	var/scale_factor = (scale / src.marker_scale)
	src.marker.Scale(scale_factor, scale_factor)
	src.marker_scale = scale
