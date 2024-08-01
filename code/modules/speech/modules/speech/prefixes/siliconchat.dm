/datum/speech_module/prefix/premodifier/channel/silicon
	id = SPEECH_PREFIX_SILICON
	priority = SPEECH_PREFIX_PRIORITY_LOW
	prefix_id = ":s"
	channel_id = SAY_CHANNEL_SILICON

/datum/speech_module/prefix/premodifier/channel/silicon/get_prefix_choices()
	. = list()

	var/channel_name
	if (isAI(src.parent_tree.speaker_origin))
		channel_name = "* - Robot Talk"
	else
		channel_name = "Robot Talk: \[***\]"

	.[channel_name] = ":s"
