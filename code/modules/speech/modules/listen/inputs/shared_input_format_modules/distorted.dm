ABSTRACT_TYPE(/datum/shared_input_format_module/distorted)
/datum/shared_input_format_module/distorted

/datum/shared_input_format_module/distorted/process(datum/say_message/message)
	. = message

	if (isnull(message.speaker_to_display))
		message.speaker_to_display = message.real_ident

	message.speaker_to_display = radioGarbleText(message.speaker_to_display, FLOCK_RADIO_GARBLE_CHANCE / 2)
	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(radioGarbleText), FLOCK_RADIO_GARBLE_CHANCE / 2))


/datum/shared_input_format_module/distorted/radio
	id = LISTEN_INPUT_RADIO_DISTORTED


/datum/shared_input_format_module/distorted/siliconchat
	id = LISTEN_INPUT_SILICONCHAT_DISTORTED
