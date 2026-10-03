/**
 * tgui state: can_see_state
 *
 * Checks to see if the user can see the thing (i.e they aren't blind or wearing a blindfold/bucket/blanket/whatever else blocks vision).
 */
var/global/datum/ui_state/tgui_can_see_state/tgui_can_see_state = new /datum/ui_state/tgui_can_see_state

/datum/ui_state/tgui_can_see_state/can_use_topic(src_object, mob/user)
	if(user.sight_check(1))
		return UI_INTERACTIVE
	return UI_CLOSE
