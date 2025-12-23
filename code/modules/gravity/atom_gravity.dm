// See also `/datum/lifeprocess/gravity`

/// The last gforce value applied to this AM
/atom/movable/var/gforce = 1

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

// intangibles never effected by gravity
/mob/living/intangible/set_gravity(new_gforce)
	return

/mob/dead/set_gravity(new_gforce)
	return

// Force snappier HUD updates

/mob/living/carbon/human/set_gravity(new_gforce)
	. = ..()
	src.hud?.update_gravity_indicator()

/mob/living/critter/set_gravity(new_gforce)
	. = ..()
	src.hud?.update_gravity_indicator()

/mob/living/silicon/robot/set_gravity(new_gforce)
	. = ..()
	src.hud?.update_gravity_indicator()

