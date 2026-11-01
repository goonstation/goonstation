/datum/speech_module/modifier/mute
	id = SPEECH_MODIFIER_MUTE
	priority = SPEECH_MODIFIER_PRIORITY_PROCESS_FIRST

/datum/speech_module/modifier/mute/process(datum/say_message/message)
	if (message.output_module_channel != SAY_CHANNEL_OUTLOUD)
		return message

	boutput(message.speaker, SPAN_ALERT("You seem to be unable to speak."))
	return NO_MESSAGE
