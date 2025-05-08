/datum/message_modifier/preprocessing/whisper
	sayflag = SAYFLAG_WHISPER

/datum/message_modifier/preprocessing/whisper/process(datum/say_message/message)
	. = message

	message.say_sound = NO_SAY_SOUND
	message.heard_range = WHISPER_EAVESDROPPING_RANGE


/datum/message_modifier/postprocessing/whisper
	sayflag = SAYFLAG_WHISPER

/datum/message_modifier/postprocessing/whisper/process(datum/say_message/message)
	. = message

	message.flags |= SAYFLAG_NO_MAPTEXT
	message.say_verb = message.whisper_verb
	message.format_content_style_prefix = "<i>"
	message.format_content_style_suffix = "</i>"
