/datum/element/stick_to_walls/Attach(atom/movable/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	src.RegisterSignal(target, COMSIG_BUILD_FROM_FRAME, PROC_REF(stick))
	src.stick(target)

	. = ..()

/datum/element/stick_to_walls/proc/stick(atom/movable/target)
	if (!istype(target) || !isturf(target.loc))
		return
	var/turf/T = null
	var/direction_order = list(target.dir) | list(NORTH, EAST, WEST, SOUTH)
	for (var/dir in direction_order) //Not global.cardinal so that we only stick to the south wall as a last resort
		T = get_step(target,dir)
		if (iswall(T))
			target.set_dir(dir)
			break
