/datum/speech_module/prefix/premodifier/channel/intruderchat
	id = SPEECH_PREFIX_INTRUDERCHAT
	priority = SPEECH_PREFIX_PRIORITY_LOW
	prefix_id = PREFIX_TEXT_INTRUDER
	channel_id = SAY_CHANNEL_INTRUDER

/datum/speech_module/prefix/premodifier/channel/intruderchat/get_prefix_choices()
	return list("Intrusion chat" = PREFIX_TEXT_INTRUDER)
