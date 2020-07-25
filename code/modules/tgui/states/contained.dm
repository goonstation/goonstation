/**
 * tgui state: contained_state
 *
 * Checks that the user is inside the src_object.
 */
var/global/datum/ui_state/tgui_contained_state/tgui_contained_state = new /datum/ui_state/tgui_contained_state

/datum/ui_state/tgui_contained_state/can_use_topic(atom/src_object, mob/user)
	if(!src_object.contains(user))
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
