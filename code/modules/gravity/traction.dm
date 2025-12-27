/// Does this atom have traction against the ground?
/atom/movable/var/traction = TRACTION_FULL
/// The floating scalar component of inertia for the item.
///
/// Things will lay at rest if this drops to 0
/atom/movable/var/inertia_value = 0

/// Update the atom's traction against the ground
/atom/movable/proc/update_traction(turf/T)
	src.traction = src.calculate_traction(T)
	if (src.traction == TRACTION_FULL)
		src.inertia_value = 0
	else
		BeginSpacePush(src)

/mob/update_traction(turf/T)
	if (src.traction == TRACTION_FULL)
		src.inertia_dir = 0
	. = ..()

/// Check if an atom has traction with the ground due to gravity
/atom/movable/proc/calculate_traction(turf/T)
	if (HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE))
		return TRACTION_FULL

	if (src.no_gravity)
		return TRACTION_NONE

	if (src.anchored)
		if (isfloor(src.loc) || iswall(src.loc))
			return TRACTION_FULL

	switch (src.gforce)
		if (TRACTION_GFORCE_FULL to INFINITY)
			if (T.wet >= 2) // lube / superlube
				return TRACTION_PARTIAL
			return TRACTION_FULL
		if (-INFINITY to TRACTION_GFORCE_PARTIAL)
			if (T.wet <= -1) // slime
				if (T.wet <= -2) // glue
					return TRACTION_FULL
				return TRACTION_PARTIAL
			return TRACTION_NONE
		if (TRACTION_GFORCE_PARTIAL to TRACTION_GFORCE_FULL)
			if (T.wet <= -1) // slime/glue
				return TRACTION_FULL
			return TRACTION_PARTIAL

/obj/item/sticker/calculate_traction(turf/T)
	if (src.attached) // they're sticky
		return TRACTION_FULL
	return ..()

// TODO: integrate pod drift/RCS behavior
/obj/machinery/vehicle/calculate_traction(turf/T)
	return TRACTION_FULL

/mob/calculate_traction(turf/T)
	// admin noclip
	if (src.client?.flying || HAS_ATOM_PROPERTY(src, PROP_MOB_NOCLIP))
		return TRACTION_FULL
	if (src.is_spacefaring())
		return TRACTION_FULL
	. = ..()

/obj/critter/calculate_traction(turf/T)
	if (src.flying)
		return TRACTION_FULL
	. = ..()

// intangibles always have traction, they spookey
/mob/living/intangible/calculate_traction(turf/T)
	return TRACTION_FULL

// active hivebots hover
/mob/living/silicon/hivebot/eyebot/calculate_traction(turf/T)
	if (src.client)
		return TRACTION_FULL
	. = ..()

// ghostdrones hover
/mob/living/silicon/ghostdrone/calculate_traction(turf/T)
	return TRACTION_FULL
