/datum/speech_module/modifier/cloaked
	id = SPEECH_MODIFIER_CLOAKED

/datum/speech_module/modifier/cloaked/process(datum/say_message/message)
	. = message

	message.maptext_origin = get_turf(message.message_origin)
