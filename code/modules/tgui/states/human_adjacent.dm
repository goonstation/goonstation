/**
 * tgui state: human_adjacent_state
 *
 * In addition to default checks, only allows interaction for a
 * human adjacent user.
 */

var/global/datum/ui_state/tgui_human_adjacent_state/tgui_human_adjacent_state = new /datum/ui_state/tgui_human_adjacent_state

/datum/ui_state/tgui_human_adjacent_state/can_use_topic(src_object, mob/user)
	. = user.default_can_use_topic(src_object)

	if(!((BOUNDS_DIST(src_object, user) == 0)) || (!ishuman(user)))
		// Can't be used unless adjacent and human, even with TK
		. = min(., UI_UPDATE)
