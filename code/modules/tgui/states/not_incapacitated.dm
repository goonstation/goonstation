/**
 * tgui state: not_incapacitated_state
 *
 * Checks that the user isn't incapacitated
 */

var/global/datum/ui_state/tgui_not_incapacitated_state/tgui_not_incapacitated_state = new /datum/ui_state/tgui_not_incapacitated_state

/**
 * tgui state: not_incapacitated_turf_state
 *
 * Checks that the user isn't incapacitated and that their loc is a turf
 */

var/global/datum/ui_state/tgui_not_incapacitated_state/tgui_not_incapacitated_turf_state = new  /datum/ui_state/tgui_not_incapacitated_state(no_turfs = TRUE)

/datum/ui_state/tgui_not_incapacitated_state
	var/turf_check = FALSE

/datum/ui_state/tgui_not_incapacitated_state/New(loc, no_turfs = FALSE)
	..()
	turf_check = no_turfs

/datum/ui_state/tgui_not_incapacitated_state/can_use_topic(src_object, mob/user)
	if(istype(user, /mob/dead/target_observer))
		return UI_UPDATE
	if(user.stat)
		return UI_CLOSE
	if(!can_act(user) || (turf_check && !isturf(user.loc)))
		return UI_DISABLED
	return UI_INTERACTIVE
