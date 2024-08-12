/datum/minimap_marker
	/// The minimap datum that the minimap marker belongs to.
	var/datum/minimap/map
	/// The physical marker, determining appearance and position.
	var/atom/movable/marker
	/// The target of the minimap marker.
	var/atom/target

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
	/// Whether this minimap marker appears on the controller ui, permitting it's visibility to be toggled, or for it to be deleted.
	var/list_on_ui = TRUE

/datum/minimap_marker/New(atom/target, name, can_be_deleted_by_player = FALSE, list_on_ui = TRUE, marker_scale)
	. = ..()

	src.marker = new /atom/movable()
	src.marker.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
	src.marker.mouse_opacity = 0

	src.target = target

	if (src.target && !name)
		src.name = target.name
	else
		src.name = name

	if (src.target && istype(src.target, /atom/movable))
		src.RegisterSignal(src.target, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(handle_move))
		// Set initial marker position.
		src.handle_move(src.target, null, get_turf(src.target))

	src.can_be_deleted_by_player = can_be_deleted_by_player
	src.list_on_ui = list_on_ui
	src.scale_marker(marker_scale)

/datum/minimap_marker/disposing()
	if (!QDELETED(src.target))
		src.UnregisterSignal(src.target, XSIG_MOVABLE_TURF_CHANGED)

	src.target = null
	. = ..()

/datum/minimap_marker/proc/handle_move(thing, turf/old_turf, turf/new_turf)
	if (!src.map || !thing || !new_turf)
		return

	src.map.set_marker_position(src, new_turf.x, new_turf.y, new_turf.z)

/datum/minimap_marker/proc/scale_marker(scale)
	var/scale_factor = (scale / src.marker_scale)
	src.marker.Scale(scale_factor, scale_factor)
	src.marker_scale = scale
