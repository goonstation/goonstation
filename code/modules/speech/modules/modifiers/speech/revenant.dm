/datum/speech_module/modifier/revenant
	id = SPEECH_MODIFIER_REVENANT
	priority = 1000

/datum/speech_module/modifier/revenant/process(datum/say_message/message)
	if (message.output_module_channel != SAY_CHANNEL_OUTLOUD)
		return message

	message.speaker.visible_message(SPAN_ALERT("[message.speaker] makes some [pick("eldritch", "eerie", "otherworldly", "netherly", "spooky", "demonic", "haunting")] noises!"))
	qdel(message)
