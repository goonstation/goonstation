/**
 * tgui state: secondary_admin_state
 *
 * Checks that the user is a secondary admin or above, end-of-story.
 */
var/global/datum/ui_state/tgui_secondary_admin_state/tgui_secondary_admin_state = new /datum/ui_state/tgui_secondary_admin_state

/datum/ui_state/tgui_secondary_admin_state/can_use_topic(src_object, mob/user)
	if(isadmin(user) && user.client.holder.level >= LEVEL_SA && !user.client.player_mode)
		return UI_INTERACTIVE
	return UI_CLOSE
