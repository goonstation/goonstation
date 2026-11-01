/datum/listen_module/input/outloud/global_hearing
	id = "global_hearing_base"
	channel = SAY_CHANNEL_GLOBAL_OUTLOUD


SET_UP_LISTEN_CONTROL(/datum/listen_module/input/outloud/global_hearing/admin, LISTEN_CONTROL_TOGGLE_GLOBAL_HEARING_ADMIN)
/datum/listen_module/input/outloud/global_hearing/admin
	id = LISTEN_INPUT_GLOBAL_HEARING


SET_UP_LISTEN_CONTROL(/datum/listen_module/input/outloud/global_hearing/ghost, LISTEN_CONTROL_TOGGLE_GLOBAL_HEARING_GHOST)
/datum/listen_module/input/outloud/global_hearing/ghost
	id = LISTEN_INPUT_GLOBAL_HEARING_GHOST


/datum/listen_module/input/outloud/ears/global_counterpart
	id = "global_hearing_counterpart_base"
	priority = LISTEN_INPUT_PRIORITY_HIGH
	ignore_line_of_sight_checks = TRUE

/datum/listen_module/input/outloud/ears/global_counterpart/process(datum/say_message/message)
	message.format_speaker_prefix = "<b>" + message.format_speaker_prefix
	message.format_content_suffix += "</b>"

	. = ..()


SET_UP_LISTEN_CONTROL(/datum/listen_module/input/outloud/ears/global_counterpart/admin, LISTEN_CONTROL_TOGGLE_GLOBAL_HEARING_ADMIN)
/datum/listen_module/input/outloud/ears/global_counterpart/admin
	id = LISTEN_INPUT_GLOBAL_HEARING_LOCAL_COUNTERPART


SET_UP_LISTEN_CONTROL(/datum/listen_module/input/outloud/ears/global_counterpart/ghost, LISTEN_CONTROL_TOGGLE_GLOBAL_HEARING_GHOST)
/datum/listen_module/input/outloud/ears/global_counterpart/ghost
	id = LISTEN_INPUT_GLOBAL_HEARING_LOCAL_COUNTERPART_GHOST

/datum/listen_module/input/outloud/ears/global_counterpart/ghost/process(datum/say_message/message)
	// Prevent radio messages from being heard if they're already being picked up by the global radio module.
	if ((message.relay_flags & SAY_RELAY_RADIO) && src.parent_tree.GetInputByID(LISTEN_INPUT_RADIO_GLOBAL_GHOST)?.enabled)
		return

	. = ..()
