ABSTRACT_TYPE(/datum/minimap_marker)
/**
 *	Minimap marker datums are responsible for managing the appearance and position of a marker `atom/movable` that depicts a
 *	tracked target object.
 */
/datum/minimap_marker
	/// The physical marker, determining appearance and position.
	var/atom/movable/marker
	/// The target of the minimap marker.
	var/atom/target

/datum/minimap_marker/New(atom/target)
	. = ..()

	src.marker = new /atom/movable()
	src.marker.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
	src.marker.mouse_opacity = 0

	src.target = target

	if (istype(src.target, /atom/movable))
		src.RegisterSignal(src.target, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(handle_move))
		src.handle_move(src.target, null, get_turf(src.target))

/datum/minimap_marker/disposing()
	if (!QDELETED(src.target))
		src.UnregisterSignal(src.target, XSIG_MOVABLE_TURF_CHANGED)

	src.target = null

	. = ..()

/// Updates this marker's position on the minimap when the target moves.
/datum/minimap_marker/proc/handle_move(datum/component/component, turf/old_turf, turf/new_turf)
	return
