/// Does this atom have traction against the ground?
/atom/movable/var/traction = TRUE

/atom/movable/proc/update_traction()
	src.traction = src.has_traction()

/// Check if an atom has traction with the ground due to gravity
/atom/movable/proc/has_traction()
	if (src.no_gravity)
		return FALSE

	var/turf/T = get_turf(src)

	if (T.effective_gforce >= GRAVITY_MOB_REGULAR_THRESHOLD)
		return TRUE

	return FALSE

/obj/machinery/vehicle/has_traction()
	return TRUE

/mob/has_traction()
	if (src.gforce >= GRAVITY_MOB_MOVEMENT_THRESHOLD)
		return TRUE

	// admin noclip
	if (src.client?.flying)
		return TRUE

	if (HAS_ATOM_PROPERTY(src, PROP_MOB_NOCLIP))
		return TRUE

	if (src.is_spacefaring())
		return TRUE

	// magboots / abomination mobs
	if (src.anchored)
		if (isfloor(src.loc) || iswall(src.loc))
			return TRUE

	// in partial gravity, slime/glue will give you effective traction
	if (src.gforce > 0)
		var/turf/T = get_turf(src)
		if (T.wet < 0)
			return TRUE

	. = ..()

/obj/item/has_traction()
	var/turf/T = get_turf(src)
	// items have less ability to traction than mobs
	if (T.effective_gforce >= GRAVITY_MOB_REGULAR_THRESHOLD)
		return TRUE
	// in partial gravity, slime/glue has a chance to stick to stuff
	if (T.effective_gforce > 0)
		if (T.wet < 0 && prob(src.w_class * 10))
			return TRUE
	. = ..()

/obj/critter/has_traction()
	if (src.flying)
		return TRUE

	if (src.anchored)
		if (isfloor(src.loc) || iswall(src.loc))
			return TRUE

	. = ..()

/// Check if an atom has "grip" with something on a nearby tile, such as a wall or table
/atom/movable/proc/has_grip()
	for (var/atom/A in oview(1, src))
		if (A.stops_space_move)
			return TRUE

