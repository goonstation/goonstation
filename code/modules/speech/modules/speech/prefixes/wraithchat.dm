/datum/speech_module/prefix/premodifier/channel/wraithchat
	id = SPEECH_PREFIX_WRAITHCHAT
	priority = SPEECH_PREFIX_PRIORITY_LOW
	prefix_id = ":wraith"
	channel_id = SAY_CHANNEL_WRAITH

/datum/speech_module/prefix/premodifier/channel/wraithchat/get_prefix_choices()
	return list("Wraithchat" = ":wraith")
