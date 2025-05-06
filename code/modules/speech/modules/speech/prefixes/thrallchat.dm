/datum/speech_module/prefix/premodifier/channel/thrallchat
	id = SPEECH_PREFIX_THRALLCHAT
	priority = SPEECH_PREFIX_PRIORITY_LOW
	prefix_id = ":thrall"
	channel_id = SAY_CHANNEL_THRALL

/datum/speech_module/prefix/premodifier/channel/thrallchat/get_prefix_choices()
	return list("Thrallchat" = ":thrall")
