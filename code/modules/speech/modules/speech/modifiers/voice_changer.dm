/datum/speech_module/modifier/voice_changer
	id = SPEECH_MODIFIER_VOICE_CHANGER

/datum/speech_module/modifier/voice_changer/process(datum/say_message/message)
	. = message
	if (!isnull(message.card_ident))
		message.speaker_to_display = message.card_ident
	else
		message.speaker_to_display = "Unknown"
