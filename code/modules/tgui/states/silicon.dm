/**
 * tgui state: silicon_state
 *
 * Checks that the user is an AI/borg.
 */

var/global/datum/ui_state/tgui_silicon_state/tgui_silicon_state = new /datum/ui_state/tgui_silicon_state

/datum/ui_state/tgui_silicon_state/can_use_topic(src_object, mob/user)
	if((issilicon(user) && !isghostdrone(user)) || isAIeye(user))
		return UI_INTERACTIVE
	return UI_CLOSE
