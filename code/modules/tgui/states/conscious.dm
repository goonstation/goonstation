/**
 * tgui state: conscious_state
 *
 * Only checks if the user is conscious.
 */
var/global/datum/ui_state/tgui_conscious_state/tgui_conscious_state = new /datum/ui_state/tgui_conscious_state

/datum/ui_state/tgui_conscious_state/can_use_topic(src_object, mob/user)
	if(isalive(user))
		return UI_INTERACTIVE
	return UI_CLOSE
