/datum/speech_module/modifier/flock_gradient
	id = SPEECH_MODIFIER_FLOCK_GRADIENT

/datum/speech_module/modifier/flock_gradient/process(datum/say_message/message)
	. = message

	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS
	message.content = "[MAKE_CONTENT_MUTABLE("\"")][message.content][MAKE_CONTENT_MUTABLE("\"")]"
	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(immutable_gradientText), "#3cb5a3", "#124e43"))


/// A copy of `gradientText` that ensures that the HTML content is immutable.
/proc/immutable_gradientText(message, color_1, color_2)
	return global.gradientText(color_1, color_2, message, TRUE)
