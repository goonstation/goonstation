/datum/speech_module/prefix/premodifier/channel/thrallchat
	id = SPEECH_PREFIX_THRALLCHAT
	priority = SPEECH_PREFIX_PRIORITY_LOW
	prefix_id = CHAT_PREFIX_THRALLCHAT
	channel_id = SAY_CHANNEL_THRALL

/datum/speech_module/prefix/premodifier/channel/thrallchat/get_prefix_choices()
	return list("Thrallchat" = CHAT_PREFIX_THRALL)
