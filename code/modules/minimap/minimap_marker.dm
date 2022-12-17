/datum/minimap_marker
	var/datum/minimap/map
	var/atom/movable/marker
	var/atom/target

	var/name
	var/visible = TRUE
	var/on_minimap_z_level
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
