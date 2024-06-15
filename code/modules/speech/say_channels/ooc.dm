/datum/say_channel/ooc
	channel_id = SAY_CHANNEL_OOC
	affected_by_modifiers = FALSE
	suppress_say_sound = TRUE
	suppress_hear_sound = TRUE
	suppress_speech_bubble = TRUE

/datum/say_channel/ooc/log_message(datum/say_message/message)
	var/mob/M = message.speaker
	if (!istype(M) || !M.client || !(message.flags & SAYFLAG_SPOKEN_BY_PLAYER))
		return

	logTheThing(LOG_OOC, message.speaker, "([src.channel_id]): [message.content]")
	phrase_log.log_phrase("ooc", message.content)
