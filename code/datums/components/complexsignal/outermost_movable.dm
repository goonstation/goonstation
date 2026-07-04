/datum/component/complexsignal/outermost_movable
	/// The stored loc chain of the parent AM, starting with the parent and containing every successive loc that is an AM.
	var/list/atom/movable/loc_chain = null
	/// The number of concurrent requests for this component to listen for `COMSIG_MOVABLE_MOVED` signals on the outermost movable.
	var/track_movable_moved_requests = 0
	/// The previous turf of the outermost movable, tracked to prevent signals from firing twice.
	var/turf/previous_turf = null

/datum/component/complexsignal/outermost_movable/proc/get_outermost_movable()
	RETURN_TYPE(/atom/movable)
	return src.loc_chain[length(src.loc_chain)]

/datum/component/complexsignal/outermost_movable/proc/on_loc_change(atom/movable/thing, atom/previous_loc)
	var/atom/movable/old_outermost = src.get_outermost_movable()

	// Move through the stored loc chain and compare it to the parent's real loc chain.
	var/atom/movable/loc_crawl = src.parent
	var/break_index = 0
	var/current_index = 1
	for (var/atom/movable/AM as anything in src.loc_chain)
		// If the current loc doesn't match the expected loc, store the index at which the chain should be broken.
		if (!break_index && (loc_crawl != AM))
			break_index = current_index

		// If the chain is to be broken, unregister the signals from all locs beyond the break index.
		if (break_index)
			src.UnregisterSignal(AM, COMSIG_MOVABLE_SET_LOC)
		// Otherwise move up the real loc chain.
		else
			loc_crawl = loc_crawl.loc
			current_index++

	// Remove the incorrect locs at or beyond the break index.
	if (break_index)
		src.loc_chain.len = break_index - 1

	// Rebuild the loc chain.
	loc_crawl = src.loc_chain[length(src.loc_chain)].loc
	while (ismovable(loc_crawl))
		src.loc_chain += loc_crawl
		src.RegisterSignal(loc_crawl, COMSIG_MOVABLE_SET_LOC, PROC_REF(on_loc_change))
		loc_crawl = loc_crawl.loc

	// Now handle the appropriate signal emissions.
	var/atom/movable/new_outermost = src.get_outermost_movable()
	if (old_outermost != new_outermost)
		SEND_COMPLEX_SIGNAL(src, XSIG_OUTERMOST_MOVABLE_CHANGED, old_outermost, new_outermost)
		if (src.track_movable_moved_requests)
			src.UnregisterSignal(old_outermost, COMSIG_MOVABLE_MOVED)
			src.RegisterSignal(new_outermost, COMSIG_MOVABLE_MOVED, PROC_REF(on_turf_change))

	src.on_turf_change(thing, previous_loc)

/datum/component/complexsignal/outermost_movable/proc/on_turf_change(atom/movable/thing, atom/previous_loc)
	var/atom/movable/outermost_movable = src.get_outermost_movable()

	var/turf/old_turf = src.previous_turf
	var/turf/new_turf = get_turf(outermost_movable)
	src.previous_turf = new_turf

	if (old_turf != new_turf)
		SEND_COMPLEX_SIGNAL(src, XSIG_MOVABLE_TURF_CHANGED, old_turf, new_turf)

		var/area/old_area = get_area(previous_loc)
		var/area/new_area = get_area(outermost_movable)
		if (old_area != new_area)
			SEND_COMPLEX_SIGNAL(src, XSIG_MOVABLE_AREA_CHANGED, old_area, new_area)

		var/old_z = isnull(old_turf) ? 0 : old_turf.z
		var/new_z = isnull(new_turf) ? 0 : new_turf.z
		if (old_z != new_z)
			SEND_COMPLEX_SIGNAL(src, XSIG_MOVABLE_Z_CHANGED, old_z, new_z)

/datum/component/complexsignal/outermost_movable/Initialize()
	if (!ismovable(src.parent))
		return COMPONENT_INCOMPATIBLE
	src.RegisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC, PROC_REF(on_loc_change))
	src.loc_chain = list(src.parent)
	src.previous_turf = get_turf(src.parent)
	src.on_loc_change()
	. = ..()

/datum/component/complexsignal/outermost_movable/UnregisterFromParent()
	for (var/atom/movable/AM as anything in src.loc_chain)
		src.UnregisterSignal(AM, COMSIG_MOVABLE_SET_LOC)
		src.UnregisterSignal(AM, COMSIG_MOVABLE_MOVED)
	src.loc_chain.len = 0
	src.previous_turf = null
	. = ..()

/datum/component/complexsignal/outermost_movable/_register(datum/listener, datum/xsig/outermost_movable/xsignal, proctype, override = FALSE, ...)
	. = ..()
	// If the complex signal tracks movement, increment the request counter.
	// Then, if the request counter was 0, register the `COMSIG_MOVABLE_MOVED` signal.
	if (xsignal::track_movable_moved && !(src.track_movable_moved_requests++))
		src.RegisterSignal(src.get_outermost_movable(), COMSIG_MOVABLE_MOVED, PROC_REF(on_turf_change))

/datum/component/complexsignal/outermost_movable/_unregister(datum/listener, datum/xsig/outermost_movable/xsignal)
	. = ..()
	// If the complex signal tracks movement, decrement the request counter.
	// Then, if the request counter is now 0, unregister the `COMSIG_MOVABLE_MOVED` signal.
	if (xsignal::track_movable_moved && !(--src.track_movable_moved_requests))
		src.UnregisterSignal(src.get_outermost_movable(), COMSIG_MOVABLE_MOVED)
