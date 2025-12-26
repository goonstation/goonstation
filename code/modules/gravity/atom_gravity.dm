// See also `/datum/lifeprocess/gravity`
#define GRAVITY_LIVING_FLOAT_ANIM_TIME 25

/// The last gforce value applied to this AM
/atom/movable/var/gforce = 1
/atom/movable/var/floating_anim = FALSE

/// Reset gforce based on turf gravity
/atom/movable/proc/reset_gravity()
	var/turf/T = get_turf(src)
	if (istype(T))
		src.set_gravity(T.effective_gforce)

/// set the gforce applied to the AM and update traction
/atom/movable/proc/set_gravity(new_gforce)
	if (HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE))
		return
	if (src.no_gravity)
		new_gforce = 0
	src.gforce = new_gforce
	src.update_traction()

// gravity interactions

// fluid icons change in low-g
/obj/fluid/set_gravity(new_gforce)
	. = ..()
	src.UpdateIcon()

// intangibles/dead never affected by gravity
/mob/living/intangible/set_gravity(new_gforce)
	return
/mob/dead/set_gravity(new_gforce)
	return

// some things float in zero-G

/mob/living/carbon/human/set_gravity(new_gforce)
	. = ..()
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_FLOAT_ANIM_TIME)
			src.floating_anim = TRUE
	src.hud?.update_gravity_indicator() // snappy HUD updates

/mob/living/critter/set_gravity(new_gforce)
	. = ..()
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_FLOAT_ANIM_TIME)
			src.floating_anim = TRUE
	src.hud?.update_gravity_indicator()

/mob/living/silicon/robot/set_gravity(new_gforce)
	. = ..()
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_FLOAT_ANIM_TIME)
			src.floating_anim = TRUE
	src.hud?.update_gravity_indicator()

/mob/living/silicon/ai/set_gravity(new_gforce)
	. = ..()
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_FLOAT_ANIM_TIME)
			src.floating_anim = TRUE

// hopefuly this does not break anything ( :
/obj/fake_attacker/set_gravity(new_gforce)
	. = ..()
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_FLOAT_ANIM_TIME)
			src.floating_anim = TRUE

/obj/critter/set_gravity(new_gforce)
	. = ..()
	if (src.floating_anim)
		if (src.traction == TRACTION_FULL)
			animate(src, flags=ANIMATION_END_LOOP, tag="grav_drift")
			src.floating_anim = FALSE
	else
		if (src.traction != TRACTION_FULL && src.gforce < 1)
			animate_drift(src, -1, GRAVITY_LIVING_FLOAT_ANIM_TIME)
			src.floating_anim = TRUE

// TODO: Using animate() for potentially thousands of items isn't performant enough at this time
// /obj/item/set_gravity(new_gforce)
// 	. = ..()
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

#undef GRAVITY_LIVING_FLOAT_ANIM_TIME
