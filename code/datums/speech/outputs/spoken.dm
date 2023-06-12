TYPEINFO(/datum/speech_module/output/spoken)
	id = "spoken"
/datum/speech_module/output/spoken
	id = "spoken"
	channel = SAY_CHANNEL_OUTLOUD

	process(datum/say_message/message)
		var/mob/mob_speaker = message.speaker
		if(istype(mob_speaker) && mob_speaker.client)
			if(message.flags & SAYFLAG_SINGING)
				phrase_log.log_phrase("sing", message.content, user = message.ident_speaker, strip_html = TRUE)
			else
				phrase_log.log_phrase("say", message.content, user = message.ident_speaker, strip_html = TRUE)
		. = ..()

