TYPEINFO(/datum/speech_module/output/radio)
	id = "radio"
/datum/speech_module/output/radio
	id = "radio"
	channel = SAY_CHANNEL_RADIO_PREFIX+"none"

	process(datum/say_message/message)
		//if it's already been sent by radio, don't send it again, so flag that
		if(message.flags & SAYFLAG_RADIO_SENT)
			return null
		message.flags |= SAYFLAG_RADIO_SENT
		phrase_log.log_phrase("radio", message.content, user = message.ident_speaker, strip_html = TRUE)
		. = ..()
