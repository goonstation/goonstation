/datum/listen_module/input/global_radio
	id = LISTEN_INPUT_RADIO_GLOBAL
	channel = SAY_CHANNEL_GLOBAL_RADIO


SET_UP_LISTEN_CONTROL(/datum/listen_module/input/global_radio/ghost, LISTEN_CONTROL_TOGGLE_GHOST_RADIO)
/datum/listen_module/input/global_radio/ghost
	id = LISTEN_INPUT_RADIO_GLOBAL_GHOST


/datum/listen_module/input/distorted_radio
	id = LISTEN_INPUT_RADIO_DISTORTED
	priority = LISTEN_INPUT_PRIORITY_DISTORTED
	channel = SAY_CHANNEL_GLOBAL_RADIO


/datum/listen_module/input/global_radio_default_only
	id = LISTEN_INPUT_RADIO_GLOBAL_DEFAULT_ONLY
	channel = SAY_CHANNEL_GLOBAL_RADIO_DEFAULT_ONLY


/datum/listen_module/input/global_radio_unprotected_only
	id = LISTEN_INPUT_RADIO_GLOBAL_UNPROTECTED_ONLY
	channel = SAY_CHANNEL_GLOBAL_RADIO_UNPROTECTED_ONLY
