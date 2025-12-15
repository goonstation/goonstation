/// Check if an atom has traction with the ground due to gravity
/atom/movable/proc/has_traction()
	if (src.no_gravity)
		return FALSE

	var/turf/T = get_turf(src)
	if (T.effective_gforce >= GRAVITY_MOB_MOVEMENT_THRESHOLD)
		return TRUE
	// in partial gravity, slime/glue will give you effective traction
	if (T.effective_gforce > 0)
		if (T.wet < 0)
			return TRUE

	return FALSE

/obj/machinery/vehicle/has_traction()
	return TRUE

/mob/has_traction()
	if (src.is_spacefaring())
		return TRUE

	if (src.anchored) // magboots and abomination mobs
		if (isfloor(src.loc) || iswall(src.loc))
			return TRUE
	. = ..()

/obj/critter/has_traction()
	if (src.flying)
		return TRUE
	. = ..()

/// Check if an atom has "grip" with something on a nearby tile, such as a wall or table
/atom/movable/proc/has_grip()
	for (var/atom/A in oview(1, src))
		if (A.stops_space_move)
			return TRUE

/// Does this atom have traction against the ground?
/atom/movable/var/traction = TRUE
/atom/movable/proc/update_traction()
	traction = src.has_traction()
