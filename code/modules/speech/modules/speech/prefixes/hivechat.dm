/datum/speech_module/prefix/premodifier/channel/hivemind
	id = SPEECH_PREFIX_HIVECHAT
	priority = SPEECH_PREFIX_PRIORITY_LOW
	prefix_id = PREFIX_TEXT_HIVECHAT
	channel_id = SAY_CHANNEL_HIVEMIND

/datum/speech_module/prefix/premodifier/channel/hivemind/get_prefix_choices()
	return list("Hivechat" = PREFIX_TEXT_HIVECHAT)
