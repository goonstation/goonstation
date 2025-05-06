/datum/speech_module/prefix/premodifier/channel/deadchat
	id = SPEECH_PREFIX_DEADCHAT
	priority = SPEECH_PREFIX_PRIORITY_LOW
	prefix_id = ":d"
	channel_id = SAY_CHANNEL_DEAD

/datum/speech_module/prefix/premodifier/channel/deadchat/get_prefix_choices()
	return list("Deadchat" = ":d")
