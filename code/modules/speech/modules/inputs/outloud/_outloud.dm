/datum/listen_module/input/outloud
	id = LISTEN_INPUT_OUTLOUD
	channel = SAY_CHANNEL_OUTLOUD
	var/hearing_range = 5

/datum/listen_module/input/outloud/proc/can_hear(datum/say_message/message)
	// If the hearing range is less than the message's heard range, ensure that the speaker and listener are within that range.
	if ((src.hearing_range < message.heard_range) && !IN_RANGE(src.parent_tree.parent, message.speaker, src.hearing_range))
		return FALSE

	return TRUE

/datum/listen_module/input/outloud/process(datum/say_message/message)
	if (!src.can_hear(message))
		return

	. = ..()


/datum/listen_module/input/outloud/range_0
	id = LISTEN_INPUT_OUTLOUD_RANGE_0
	hearing_range = 0


/datum/listen_module/input/outloud/range_1
	id = LISTEN_INPUT_OUTLOUD_RANGE_1
	hearing_range = 1
