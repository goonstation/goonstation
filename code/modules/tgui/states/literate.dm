/**
 * tgui state: literate_state
 *
 * Checks to see if the user can read.
 */
var/global/datum/ui_state/tgui_literate_state/tgui_literate_state = new /datum/ui_state/tgui_literate_state

/datum/ui_state/tgui_literate_state/can_use_topic(src_object, mob/user)
	if(user.literate == 1)
		return UI_INTERACTIVE
	return UI_CLOSE
