TYPEINFO(/datum/speech_module/output/spoken)
	id = "spoken"
/datum/speech_module/output/spoken
	id = "spoken"
	channel = SAY_CHANNEL_OUTLOUD
	priority = -1 //lower than default (0)

	process(datum/say_message/message)
		var/mob/mob_speaker = message.speaker
		if(istype(mob_speaker) && mob_speaker.client)
			if(message.flags & SAYFLAG_SINGING)
				logTheThing(LOG_DIARY, src, "(SINGING): [message]", "say")
				phrase_log.log_phrase("sing", message.content, user = message.ident_speaker, strip_html = TRUE)
			else if(message.flags & SAYFLAG_WHISPER)
				logTheThing(LOG_DIARY, src, "(WHISPER): [message]", "whisper")
				logTheThing(LOG_WHISPER, src, "SAY: [message]")
				phrase_log.log_phrase("whisper", message.content, user = message.ident_speaker, strip_html = TRUE)
			else
				logTheThing(LOG_DIARY, src, ": [message]", "say")
				phrase_log.log_phrase("say", message.content, user = message.ident_speaker, strip_html = TRUE)
		. = ..()

