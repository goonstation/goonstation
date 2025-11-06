/datum/speech_module/modifier/muzzle
	id = SPEECH_MODIFIER_MUZZLE
	priority = SPEECH_MODIFIER_PRIORITY_PROCESS_FIRST

/datum/speech_module/modifier/muzzle/process(datum/say_message/message)
	if (message.output_module_channel != SAY_CHANNEL_OUTLOUD)
		return message

	boutput(message.speaker, SPAN_ALERT("Your muzzle prevents you from speaking."))
	return NO_MESSAGE
