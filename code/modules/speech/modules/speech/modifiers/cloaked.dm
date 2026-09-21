/datum/speech_module/modifier/cloaked
	id = SPEECH_MODIFIER_CLOAKED

/datum/speech_module/modifier/cloaked/process(datum/say_message/message)
	. = message

	if ((message.output_module_channel != SAY_CHANNEL_OUTLOUD) || (message.flags & SAYFLAG_WHISPER) || message.prefix)
		return

	message.maptext_origin = get_turf(message.message_origin)
