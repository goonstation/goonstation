/**
 * tgui state: observer_state
 *
 * Checks that the user is an observer/ghost.
 */

var/global/datum/ui_state/tgui_observer_state/tgui_observer_state = new /datum/ui_state/tgui_observer_state

/datum/ui_state/tgui_observer_state/can_use_topic(src_object, mob/user)
	if(isobserver(user))
		return UI_INTERACTIVE
	return UI_CLOSE

