/datum/element/stick_to_walls/Attach(atom/movable/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	. = ..()
	var/turf/T = null
	var/direction_order = list(target.dir) | list(NORTH, EAST, WEST, SOUTH)
	for (var/dir in direction_order) //Not global.cardinal so that we only stick to the south wall as a last resort
		T = get_step(target,dir)
		if (iswall(T))
			target.set_dir(dir)
			break

	target.RemoveElement(/datum/element/stick_to_walls) //Only stick it once, then remove self
	// There's probably a sane way to make a version of this that persists on the target and checks if it has no wall its stuck to and restick it
	// But I couldn't figure it out and its not really necessary
