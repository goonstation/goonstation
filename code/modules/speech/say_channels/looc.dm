/datum/say_channel/delimited/local/looc
	channel_id = SAY_CHANNEL_LOOC
	affected_by_modifiers = FALSE
	suppress_say_sound = TRUE
	suppress_hear_sound = TRUE
	suppress_speech_bubble = TRUE

/datum/say_channel/delimited/local/looc/GetAtomListeners(datum/say_message/message)
	return range(message.speaker, LOOC_RANGE)

/datum/say_channel/ooc/log_message(datum/say_message/message)
	var/mob/M = message.speaker
	if (!istype(M) || !M.client || !(message.flags & SAYFLAG_SPOKEN_BY_PLAYER))
		return

	logTheThing(LOG_OOC, message.speaker, "([src.channel_id]): [message.content]")
	phrase_log.log_phrase("looc", message.content)


/datum/say_channel/global_channel/looc
	channel_id = SAY_CHANNEL_GLOBAL_LOOC
	delimited_channel_id = SAY_CHANNEL_LOOC
	affected_by_modifiers = FALSE
	suppress_say_sound = TRUE
	suppress_hear_sound = TRUE
	suppress_speech_bubble = TRUE
