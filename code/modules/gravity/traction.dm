/// Does this atom have traction against the ground?
/atom/movable/var/traction = TRACTION_FULL
/// The float scalar component of inertia for the atom.
///
/// Things will drop out of the force-push loop if this is zero
/atom/movable/var/inertia_value = 0

proc/StartDriftFloat(atom/movable/AM)
	if (!(AM.temp_flags & DRIFT_ANIMATION))
		AM.temp_flags |= DRIFT_ANIMATION
		animate(AM, flags=ANIMATION_END_NOW, tag="grav_drift") // reset animations so they don't stack
		animate_drift(AM, -1, 25)

proc/StopDriftFloat(atom/movable/AM)
	AM.temp_flags &= ~DRIFT_ANIMATION
	animate(AM, flags=ANIMATION_END_NOW, tag="grav_drift")

/// Update the atom's traction against the ground
/atom/movable/proc/update_traction(turf/T)
	return_if_overlay_or_effect(src)
	src.traction = src.calculate_traction(T)

	if (src.traction == TRACTION_FULL || src.has_grip())
		if (src.temp_flags & SPACE_PUSHING)
			EndSpacePush(src)
		else if (src.inertia_value != 0)
			src.inertia_value = 0
	else
		if(!(src.temp_flags & SPACE_PUSHING) && src.inertia_value > 0  && src.last_move != null)
			BeginSpacePush(src)

	if (src.floats_in_zero_g)
		if (src.traction == TRACTION_FULL)
			StopDriftFloat(src)
			return
		if (src.gforce >= GFORCE_EARTH_GRAVITY)
			StopDriftFloat(src)
			return
		StartDriftFloat(src)

/mob/update_traction(turf/T)
	. = ..()
	if (src.traction == TRACTION_FULL && src.inertia_dir != 0)
		src.inertia_dir = 0

/// Check if an atom has traction with the ground due to gravity
/atom/movable/proc/calculate_traction(turf/T=null)
	if (!isturf(src.loc) || HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE))
		return TRACTION_FULL

	if (!istype(T))
		T = get_turf(src)

	if (!T)
		return TRACTION_FULL

	if (src.anchored == ANCHORED_ALWAYS)
		return TRACTION_FULL
	else if (src.anchored == ANCHORED)
		if (isfloor(src.loc) || iswall(src.loc))
			return TRACTION_FULL

	if (T.active_liquid)
		var/obj/fluid/F = T.active_liquid
		if (F.amt > 200)
			return TRACTION_FULL

	if (src.no_gravity)
		return TRACTION_NONE

	switch (src.gforce)
		if (GFORCE_TRACTION_FULL to INFINITY)
			if (T.wet >= 2 || HAS_ATOM_PROPERTY(src, PROP_ATOM_FLOATING)) // lube / superlube / floating
				return TRACTION_PARTIAL
			return TRACTION_FULL
		if (GFORCE_TRACTION_PARTIAL to GFORCE_TRACTION_FULL)
			if (T.wet <= -1) // slime/glue
				return TRACTION_FULL
			return TRACTION_PARTIAL
		if (-INFINITY to GFORCE_TRACTION_PARTIAL)
			if (T.wet <= -1) // slime
				if (T.wet <= -2) // glue
					return TRACTION_FULL
				return TRACTION_PARTIAL
			return TRACTION_NONE

/mob/calculate_traction(turf/T)
	if (src.client?.flying || HAS_ATOM_PROPERTY(src, PROP_MOB_NOCLIP) || HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE))
		return TRACTION_FULL
	if (src.is_spacefaring())
		return TRACTION_FULL
	. = ..()

/obj/critter/calculate_traction(turf/T)
	if (src.flying)
		return TRACTION_FULL
	. = ..()

// active hivebots hover
/mob/living/silicon/hivebot/eyebot/calculate_traction(turf/T)
	if (src.client)
		return TRACTION_FULL
	. = ..()

// ghostdrones hover
/mob/living/silicon/ghostdrone/calculate_traction(turf/T)
	return TRACTION_FULL

