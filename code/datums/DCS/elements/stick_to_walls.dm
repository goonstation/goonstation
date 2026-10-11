/datum/element/stick_to_walls/Attach(atom/movable/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	. = ..()
	var/turf/T = null
	for (var/dir in list(NORTH, EAST, WEST, SOUTH)) //Not global.cardinal so that we only stick to the south wall as a last resort
		T = get_step(target,dir)
		if (iswall(T))
			target.set_dir(dir)
			break

	src.Detach(target) //Only stick it once, then remove self
	// There's probably a sane way to make a version of this that persists on the target and checks if it has no wall its stuck to and restick it
	// But I couldn't figure it out and its not really necessary
