/datum/minimap_marker
	///The minimap datum that the minimap marker belongs to.
	var/datum/minimap/map
	///The physical marker, determining appearance and position.
	var/atom/movable/marker
	///The target of the minimap marker.
	var/atom/target

	///The name of the minimap marker, usually inherited from the target, unless overridden on creation.
	var/name
	///Whether the minimap marker is visible, with precedence over alpha settings.
	var/visible = TRUE
	///Whether the target is on the minimap datum's rendered z-level, determining whether it is displayed.
	var/on_minimap_z_level = FALSE
	///Whether the minimap marker can be deleted by players using minimap controllers.
	var/can_be_deleted_by_player = FALSE

	New(var/atom/target, var/name, var/can_be_deleted_by_player)
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
			src.RegisterSignal(target, COMSIG_MOVABLE_SET_LOC, .proc/handle_move)
			src.RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/handle_move)
			src.handle_move(target)

		if (can_be_deleted_by_player)
			src.can_be_deleted_by_player = can_be_deleted_by_player

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
