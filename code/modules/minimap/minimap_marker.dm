/datum/minimap_marker
	///The minimap datum that the minimap marker belongs to.
	var/datum/minimap/map
	///The physical marker, determining appearance and position.
	var/atom/movable/marker
	///The target of the minimap marker.
	var/atom/target

	///The name of the minimap marker, usually inherited from the target, unless overridden on creation.
	var/name = "Minimap Marker"
	///Whether the minimap marker is visible, with precedence over alpha settings.
	var/visible = TRUE
	///The alpha value that the minimap marker should use when visible.
	var/alpha_value = 255
	///The desired scale of the minimap marker, as a multiple of the original size (32x32px).
	var/marker_scale = 1
	///Whether the target is on the minimap datum's rendered z-level, determining whether it is displayed.
	var/on_minimap_z_level = FALSE
	///Whether the minimap marker can be deleted by players using minimap controllers.
	var/can_be_deleted_by_player = FALSE
	///Whether this minimap marker appears on the controller ui, permitting it's visibility to be toggled, or for it to be deleted.
	var/list_on_ui = TRUE

	New(var/atom/target, var/name, var/can_be_deleted_by_player = FALSE, var/list_on_ui = TRUE, var/marker_scale)
		. = ..()
		src.marker = new /atom/movable
		src.target = target

		src.marker.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
		src.marker.mouse_opacity = 0

		if (target && !name)
			src.name = target.name
		else
			src.name = name

		if (target && istype(target, /atom/movable))
			src.RegisterSignal(target, COMSIG_MOVABLE_SET_LOC, PROC_REF(handle_move))
			src.RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
			src.handle_move(target)

		src.can_be_deleted_by_player = can_be_deleted_by_player
		src.list_on_ui = list_on_ui
		src.scale_marker(marker_scale)

	disposing()
		src.UnregisterSignal(target, COMSIG_MOVABLE_SET_LOC)
		src.UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
		. = ..()

	proc/handle_move(var/atom/movable/target)
		if (!map || !target)
			return

		var/turf/T = get_turf(target)
		if (!T)
			return
		map.set_marker_position(src, T.x, T.y, T.z)

	proc/scale_marker(var/scale)
		var/scale_factor = (scale / src.marker_scale)
		src.marker.Scale(scale_factor, scale_factor)
		src.marker_scale = scale
