/// The last gforce value applied to this AM
/atom/movable/var/gforce = GFORCE_EARTH_GRAVITY
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
	SHOULD_CALL_PARENT(TRUE)
	return_if_overlay_or_effect(src)
	// TODO: maybe this should be the same thing?
	if ((src.event_handler_flags & IMMUNE_TRENCH_WARP) || HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE))
		return TRUE
	if (!istype(T))
		T = get_turf(src)
		if (!istype(T))
			return TRUE
	var/new_gforce = T.get_gforce_current()
	if (src.no_gravity) // negative matter
		new_gforce = 0
	if (HAS_ATOM_PROPERTY(src, PROP_ATOM_FLOATING)) // floating things don't get hit with high-G
		new_gforce = min(new_gforce, 1)
	if (src.gforce == new_gforce)
		return TRUE
	var/gforce_immune = HAS_ATOM_PROPERTY(src, PROP_ATOM_GRAVITY_IMMUNE) || HAS_ATOM_PROPERTY(src.loc, PROP_ATOM_GRAVITY_IMMUNE_INSIDE)
	src.gforce_threshold_changes(src.gforce, new_gforce, gforce_immune)
	src.gforce = new_gforce
	return FALSE

/// Called when gforce changes
/atom/movable/proc/gforce_threshold_changes(old_gforce, new_gforce, gforce_immune=FALSE)
	SHOULD_CALL_PARENT(TRUE)

/mob/living/carbon/floats_in_zero_g = TRUE
/mob/living/carbon/gforce_threshold_changes(old_gforce, new_gforce, gforce_immune)
	. = ..()
	if (new_gforce < GFORCE_GRAVITY_MINIMUM && !gforce_immune)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
		APPLY_ATOM_PROPERTY(src, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
	else
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")

	if (new_gforce >= GFORCE_MOB_HIGH_THRESHOLD && !gforce_immune)
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/gravity, "gravity")
	else
		REMOVE_MOVEMENT_MODIFIER(src, /datum/movement_modifier/gravity, "gravity")

/mob/living/carbon/human/set_gravity(turf/T)
	. = ..()
	if (.)
		return TRUE
	src.hud?.update_gravity_indicator()

/mob/living/carbon/human/gforce_threshold_changes(old_gforce, new_gforce, gforce_immune)
	. = ..()
	if (new_gforce >= GFORCE_MOB_GREYOUT_THRESHOLD && !gforce_immune)
		if (old_gforce < GFORCE_MOB_GREYOUT_THRESHOLD)
			boutput(src, SPAN_ALERT("The overhwelming gravity blurs your vision!"))
		src.addOverlayComposition(/datum/overlayComposition/greyout)
	else
		src.removeOverlayComposition(/datum/overlayComposition/greyout)

	if (new_gforce >= GFORCE_MOB_TUNNEL_VISION_THRESHOLD && !gforce_immune)
		if (old_gforce < GFORCE_MOB_TUNNEL_VISION_THRESHOLD)
			boutput(src, SPAN_ALERT("The overhwelming gravity narrows your vision!"))
		src.addOverlayComposition(/datum/overlayComposition/steelmask/tunnel_vision)

		if (new_gforce >= GFORCE_MOB_PANCAKE_THRESHOLD && src.bioHolder && !src.bioHolder.HasEffect("dwarf"))
			src.bioHolder.AddEffect("dwarf", do_stability = FALSE, scannable = FALSE, innate = TRUE)
	else
		src.removeOverlayComposition(/datum/overlayComposition/steelmask/tunnel_vision)

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

/mob/living/silicon/robot/gforce_threshold_changes(old_gforce, new_gforce, gforce_immune)
	. = ..()

	if (new_gforce < GFORCE_GRAVITY_MINIMUM && !gforce_immune)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
		APPLY_ATOM_PROPERTY(src, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
	else
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")

	if (new_gforce >= GFORCE_MOB_HIGH_THRESHOLD && !gforce_immune)
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/gravity, "gravity")
	else
		REMOVE_MOVEMENT_MODIFIER(src, /datum/movement_modifier/gravity, "gravity")

	if (new_gforce >= GFORCE_MOB_EXTREME_THRESHOLD  && !gforce_immune && istype(src.part_head, /obj/item/parts/robot_parts/head/screen))
		var/obj/item/parts/robot_parts/head/screen/screen_head = src.part_head
		if (!screen_head.smashed)
			boutput(src, SPAN_ALERT("The overhwleming gravity fractures the glass on your screen head!"))
			playsound(src, 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 30, TRUE)
			screen_head.smashed = TRUE
			screen_head.UpdateIcon()
			src.update_bodypart("head")

/mob/living/silicon/ai/floats_in_zero_g = TRUE

/obj/New()
	. = ..()
	if (src.floats_in_zero_g)
		SubscribeGravity(src)

/obj/disposing()
	if (src.floats_in_zero_g)
		UnsubscribeGravity(src)
	. = ..()

// These should act like mobs
/obj/critter/floats_in_zero_g = TRUE
/obj/fake_attacker/floats_in_zero_g = TRUE

// Cross-triggered things that work in zero-G need to indicate they're still dangerous
/obj/item/beartrap/floats_in_zero_g = TRUE
/obj/item/mine/floats_in_zero_g = TRUE

// fluid icons change in Zero-G
/obj/fluid/New(atom/location)
	. = ..()
	SubscribeGravity(src)
/obj/fluid/disposing()
	. = ..()
	UnsubscribeGravity(src)

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
