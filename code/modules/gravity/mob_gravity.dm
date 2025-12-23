// See also `/datum/lifeprocess/gravity`

/// The last gforce value applied to mob
/mob/var/gforce = 1

/// Reset mob gforce based on turf gravity
/mob/proc/reset_gravity()
	return

/mob/living/reset_gravity()
	var/turf/T = get_turf(src)
	if (istype(T))
		src.set_gravity(T.effective_gforce)

/// Set mob gravity (also updates traction)
/mob/proc/set_gravity(new_gravity)
	return

/mob/living/set_gravity(new_gravity)
	if (HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE))
		return
	if (src.no_gravity)
		new_gravity = 0
	src.gforce = new_gravity
	src.update_traction()

// intangibles never effected by gravity
/mob/living/intangible/set_gravity(new_gravity)
	return

// Force snappier HUD updates

/mob/living/carbon/human/set_gravity(new_gravity)
	. = ..()
	src.hud?.update_gravity_indicator()

/mob/living/critter/set_gravity(new_gravity)
	. = ..()
	src.hud?.update_gravity_indicator()

/mob/living/silicon/robot/set_gravity(new_gravity)
	. = ..()
	src.hud?.update_gravity_indicator()

