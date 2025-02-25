/datum/listen_module/input/outloud/global_hearing
	id = LISTEN_INPUT_GLOBAL_HEARING
	channel = SAY_CHANNEL_GLOBAL_OUTLOUD


/datum/listen_module/input/outloud/ears/global_counterpart
	id = LISTEN_INPUT_GLOBAL_HEARING_LOCAL_COUNTERPART
	priority = LISTEN_INPUT_PRIORITY_HIGH
	ignore_line_of_sight_checks = TRUE

/datum/listen_module/input/outloud/ears/global_counterpart/process(datum/say_message/message)
	message.format_speaker_prefix = "<b>" + message.format_speaker_prefix
	message.format_content_suffix += "</b>"

	. = ..()
