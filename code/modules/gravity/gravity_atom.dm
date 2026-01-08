/// The last gforce value applied to this AM
/atom/movable/var/gforce = 1
/// Atom will apply float animation in zero-G. Don't put this on lots of objects.
/atom/movable/var/floats_in_zero_g = FALSE

/// Reset gforce based on turf gravity
/atom/movable/proc/reset_gravity()
	var/turf/T = get_turf(src)
	if (istype(T))
		src.set_gravity(T)

/// set the gforce applied to the AM
///
/// returns TRUE if no change
/atom/movable/proc/set_gravity(turf/T)
	return_if_overlay_or_effect(src)
	if ((src.event_handler_flags & IMMUNE_TRENCH_WARP) || HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE))
		return TRUE
	if (!istype(T))
		T = get_turf(src)
		if (!istype(T))
			return TRUE
	var/new_gforce = T.get_gforce_current()
	if (src.no_gravity)
		new_gforce = 0
	if (src.gforce == new_gforce)
		return TRUE
	src.gforce = new_gforce
	return FALSE

// gravity interactions

// fluid icons change in low-g
/obj/fluid/New(atom/location)
	. = ..()
	SubscribeGravity(src)
/obj/fulid/disposing()
	. = ..()
	UnsubscribeGravity(src)


// some things float in zero-G

/mob/living/carbon/human/floats_in_zero_g = TRUE
/mob/living/carbon/human/set_gravity(turf/T)
	. = ..()
	if (.)
		return TRUE
	src.hud?.update_gravity_indicator()

/mob/living/critter/floats_in_zero_g = TRUE
/mob/living/critter/set_gravity(turf/T)
	. = ..()
	if (.)
		return TRUE
	src.hud?.update_gravity_indicator()

/mob/living/silicon/robot/floats_in_zero_g = TRUE
/mob/living/silicon/robot/set_gravity(turf/T)
	. = ..()
	if (.)
		return TRUE
	src.hud?.update_gravity_indicator()

/mob/living/silicon/ai/floats_in_zero_g = TRUE

/obj/New()
	. = ..()
	if (src.floats_in_zero_g)
		SubscribeGravity(src)

/obj/disposing()
	if (src.floats_in_zero_g)
		UnsubscribeGravity(src)
	. = ..()

// simplified checks for OBJs
/obj/set_gravity(turf/T)
	. = ..()
	if (.)
		return TRUE
	if (src.floats_in_zero_g)
		if (src.gforce <= 0)
			StartDriftFloat(src)
		else
			StopDriftFloat(src)

// These should act like mobs
/obj/critter/floats_in_zero_g = TRUE
/obj/fake_attacker/floats_in_zero_g = TRUE

// Cross-triggered things that work in zero-G need to indicate they're still dangerous
/obj/item/beartrap/floats_in_zero_g = TRUE
/obj/item/mine/floats_in_zero_g = TRUE

// Fluids have different icon-states for zero-g
/obj/fluid/set_gravity(turf/T)
	. = ..()
	if (.)
		return TRUE
	src.UpdateIcon()

/obj/fluid/set_gravity(turf/T)
	. = ..()
	if (.)
		return TRUE
	src.UpdateIcon()
