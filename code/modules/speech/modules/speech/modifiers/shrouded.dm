/datum/speech_module/modifier/shrouded
	id = SPEECH_MODIFIER_SHROUDED

/datum/speech_module/modifier/shrouded/process(datum/say_message/message)
	if (message.output_module_channel == SAY_CHANNEL_THRALL)
		return message

	message.speaker_to_display = "Unknown"
	return message
