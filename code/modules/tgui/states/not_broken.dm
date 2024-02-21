/**
 * tgui state: broken
 *
 * Only checks if an object is not broken, can depend on obj type
 */

var/global/datum/ui_state/tgui_broken_state/tgui_broken_state = new /datum/ui_state/tgui_broken_state

/datum/ui_state/tgui_broken_state/can_use_topic(obj/src_object, mob/user)
	return src_object.broken_state_topic(user) // Call the individual obj-overridden procs.

/obj/proc/broken_state_topic(mob/user)
	return UI_CLOSE // Don't allow interaction by default.

/obj/machinery/broken_state_topic(mob/user)
	. = user.shared_ui_interaction(src)
	if (status & BROKEN)
		return min(., UI_CLOSE)
	else if (requires_power && status & (NOPOWER | POWEROFF))
		return min(., UI_DISABLED)
	else if (status & MAINT)
		return min(., UI_UPDATE)
