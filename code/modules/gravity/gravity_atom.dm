/// How long the Zero-G floating animation takes for mobs and mob-like things (ms)
#define GRAVITY_LIVING_ZERO_G_ANIM_TIME 25

/// The last gforce value applied to this AM
/atom/movable/var/gforce = 1
/// Atom will apply float animation in zero-G
/atom/movable/var/floats_in_zero_g = FALSE
/// Is this atom currently running a floating animation
/atom/movable/var/has_float_anim = FALSE

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
		return TRUE
	var/new_gforce = T.gforce_current
	if (src.no_gravity)
		new_gforce = 0
	if (src.gforce == new_gforce)
		return TRUE
	src.gforce = new_gforce
	return FALSE

// gravity interactions

// TODO: Fix change in G, fluid controller probs
// fluid icons change in low-g
/obj/fluid/set_gravity(turf/T)
	. = ..()
	if (.)
		return TRUE
	src.UpdateIcon()

// some things float in zero-G

/mob/living/carbon/human/floats_in_zero_g = TRUE
/mob/living/carbon/human/set_gravity(turf/T)
	. = ..()
	if (!.)
		src.hud?.update_gravity_indicator()
/mob/living/critter/floats_in_zero_g = TRUE
/mob/living/critter/set_gravity(turf/T)
	. = ..()
	if (!.)
		src.hud?.update_gravity_indicator()

/mob/living/silicon/robot/floats_in_zero_g = TRUE
/mob/living/silicon/robot/set_gravity(turf/T)
	. = ..()
	if (!.)
		src.hud?.update_gravity_indicator()

/mob/living/silicon/ai/floats_in_zero_g = TRUE
/obj/fake_attacker/floats_in_zero_g = TRUE
/obj/critter/floats_in_zero_g = TRUE

// TODO: Using animate() for potentially thousands of items isn't performant enough at this time
// /obj/item/floats_in_zero_g = TRUE
