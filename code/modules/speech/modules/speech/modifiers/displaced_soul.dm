/datum/speech_module/modifier/displaced_soul
	id = SPEECH_MODIFIER_DISPLACED_SOUL
	priority = SPEECH_MODIFIER_PRIORITY_PROCESS_FIRST

/datum/speech_module/modifier/displaced_soul/process(datum/say_message/message)
	if (message.output_module_channel != SAY_CHANNEL_OUTLOUD)
		return message

	if (!ON_COOLDOWN(message.speaker, "displaced_soul_speak", 2 SECONDS))
		message.speaker.visible_message(SPAN_ALERT("\The [message.speaker.name]'s mouth moves, but you can't tell what they're saying!"), SPAN_ALERT("Nothing comes out of your mouth!"))

	return NO_MESSAGE
