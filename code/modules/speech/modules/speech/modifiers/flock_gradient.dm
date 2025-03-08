/datum/speech_module/modifier/flock_gradient
	id = SPEECH_MODIFIER_FLOCK_GRADIENT

/datum/speech_module/modifier/flock_gradient/process(datum/say_message/message)
	. = message

	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS
	message.content = gradientText("#3cb5a3", "#124e43", "\"[message.content]\"")
