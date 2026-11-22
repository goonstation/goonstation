/// Whether this mob is lying down.
/mob/var/lying = FALSE

/// Set the mob's lying state. Do not set the variable directly.
/mob/proc/set_lying(new_lying)
	SHOULD_CALL_PARENT(TRUE)

	if (src.lying == new_lying)
		return

	src.lying = new_lying
	src.animate_lying(src.lying)
	src.p_class = src::p_class + src.lying

	global.actions.interrupt(src, INTERRUPT_ACT)
	SEND_SIGNAL(src, COMSIG_MOB_LAYDOWN_STANDUP, src.lying)

	if (!src::density || (ismobcritter(src) && isdead(src)))
		src.set_density(FALSE)
	else
		src.set_density(!src.lying)

	if (src.lying && !src.buckled && !HAS_ATOM_PROPERTY(src, PROP_MOB_SUPPRESS_LAYDOWN_SOUND))
		var/turf/T = get_turf(src)
		if (!T?.active_liquid)
			playsound(src.loc, 'sound/misc/body_thud.ogg', ishuman(src) ? 40 : 15, 1, 0.3)
		else if (T.active_liquid.my_depth_level <= 3)
			T.active_liquid.Crossed(src)
			playsound(src.loc, 'sound/misc/splash_2.ogg', ishuman(src) ? 40 : 15, 1, 0.3)

/// Perform a "lie down" animation.
/mob/proc/animate_lying(lying)
	return
