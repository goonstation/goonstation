/datum/shared_input_format_module/distorted_siliconchat
	id = LISTEN_INPUT_SILICONCHAT_DISTORTED

/datum/shared_input_format_module/distorted_siliconchat/process(datum/say_message/message)
	. = message

	if (isnull(message.speaker_to_display))
		message.speaker_to_display = message.real_ident

	message.speaker_to_display = radioGarbleText(message.speaker_to_display, FLOCK_RADIO_GARBLE_CHANCE / 2)
	message.content = radioGarbleText(message.content, FLOCK_RADIO_GARBLE_CHANCE / 2)
