/// How long the Zero-G floating animation takes for mobs and mob-like things
#define GRAVITY_LIVING_ZEROG_ANIM_TIME 25

/// The last gforce value applied to this AM
/atom/movable/var/gforce = 1
/// Is this atom currently running a floating animation
/atom/movable/var/floating_anim = FALSE

/// Reset gforce based on turf gravity
/atom/movable/proc/reset_gravity(force_update=FALSE)
	var/turf/T = get_turf(src)
	if (istype(T))
		src.set_gravity(T, force_update)

/// set the gforce applied to the AM and update traction
///
/// returns TRUE if no change
/atom/movable/proc/set_gravity(turf/T, force_update=FALSE)
	if (HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE))
		return TRUE
	if (!istype(T))
		var/turf/my_turf = get_turf(src)
		if (!istype(my_turf))
			return TRUE// nullspace?
		T = my_turf
	var/new_gforce = T.effective_gforce
	if (src.no_gravity)
		new_gforce = 0
	if (src.gforce == new_gforce && !force_update)
		return TRUE
	src.gforce = new_gforce
	src.update_traction(T)
	return FALSE

// gravity interactions

// fluid icons change in low-g
/obj/fluid/set_gravity(turf/T, force_update=FALSE)
	. = ..()
	if (.)
		return TRUE
	src.UpdateIcon()

// some things float in zero-G

/mob/living/carbon/human/set_gravity(turf/T, force_update=FALSE)
	. = ..()
	if (.)
		return TRUE
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_ZEROG_ANIM_TIME)
			src.floating_anim = TRUE
	src.hud?.update_gravity_indicator() // snappy HUD updates

/mob/living/critter/set_gravity(turf/T, force_update=FALSE)
	. = ..()
	if (.)
		return TRUE
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_ZEROG_ANIM_TIME)
			src.floating_anim = TRUE
	src.hud?.update_gravity_indicator()

/mob/living/silicon/robot/set_gravity(turf/T, force_update=FALSE)
	. = ..()
	if (.)
		return TRUE
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_ZEROG_ANIM_TIME)
			src.floating_anim = TRUE
	src.hud?.update_gravity_indicator()

/mob/living/silicon/ai/set_gravity(turf/T, force_update=FALSE)
	. = ..()
	if (.)
		return TRUE
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_ZEROG_ANIM_TIME)
			src.floating_anim = TRUE

/obj/fake_attacker/set_gravity(turf/T, force_update=FALSE)
	. = ..()
	if (.)
		return TRUE
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_ZEROG_ANIM_TIME)
			src.floating_anim = TRUE

/obj/critter/set_gravity(turf/T, force_update=FALSE)
	. = ..()
	if (.)
		return TRUE
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_ZEROG_ANIM_TIME)
			src.floating_anim = TRUE

// TODO: Using animate() for potentially thousands of items isn't performant enough at this time
// /obj/item/set_gravity(turf/T, force_update=FALSE)
// 	. = ..()
// if (.)
// 		return
// 	if (src.floating_anim)
// 		if (src.traction >= TRACTION_PARTIAL)
// 			// src.remove_filter("grav_drift")
// 			// animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
// 			src.floating_anim = FALSE
// 	else
// 		if (src.traction != TRACTION_FULL && src.gforce <= TRACTION_GFORCE_PARTIAL)
// 			// src.add_filter("grav_drift", 15, displacement_map_filter(icon=icon('icons/effects/distort.dmi', "grav")))
// 			// animate_drift(src, -1, 10 + (5 * src.w_class))
// 			src.floating_anim = TRUE

#undef GRAVITY_LIVING_ZEROG_ANIM_TIME
