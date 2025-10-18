/datum/speech_module/prefix/premodifier/channel/vampchat
	id = SPEECH_PREFIX_VAMPCHAT
	priority = SPEECH_PREFIX_PRIORITY_LOW
	prefix_id = PREFIX_TEXT_VAMPCHAT
	channel_id = SAY_CHANNEL_VAMPIRE

/datum/speech_module/prefix/premodifier/channel/vampchat/get_prefix_choices()
	return list("Vampchat" = PREFIX_TEXT_VAMPCHAT)
