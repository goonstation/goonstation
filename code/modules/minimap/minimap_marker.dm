/datum/minimap_marker
	var/datum/minimap/map
	var/atom/movable/marker
	var/atom/target

	New()
		. = ..()
		src.marker = new /atom/movable

		src.marker.vis_flags = VIS_INHERIT_ID
		src.marker.mouse_opacity = 0

/datum/minimap_marker/tracking
	New(var/atom/movable/target)
		..()
		if (!target)
			return

		src.target = target
		src.RegisterSignal(target, COMSIG_MOVABLE_SET_LOC, .proc/handle_move)
		src.RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/handle_move)
		src.handle_move(target)

	proc/handle_move(var/atom/movable/target)
		if (!map || !target)
			return

		var/turf/T = get_turf(target)
		if (!T)
			return
		map.set_marker_position(src, T.x, T.y, T.z)
