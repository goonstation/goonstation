/**
 * tgui state: always_state
 *
 * Always grants the user UI_INTERACTIVE. Period.
 */
var/global/datum/ui_state/tgui_always_state/tgui_always_state = new /datum/ui_state/tgui_always_state

/datum/ui_state/tgui_always_state/can_use_topic(src_object, mob/user)
	return UI_INTERACTIVE
