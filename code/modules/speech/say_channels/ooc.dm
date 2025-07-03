/datum/say_channel/ooc
	channel_id = SAY_CHANNEL_OOC
	disabled_message = "OOC is currently disabled. For gameplay questions, try <a href='byond://winset?command=mentorhelp'>mentorhelp</a>."
	affected_by_modifiers = FALSE
	suppress_say_sound = TRUE
	suppress_hear_sound = TRUE
	suppress_speech_bubble = TRUE

/datum/say_channel/ooc/log_message(datum/say_message/message)
	logTheThing(LOG_OOC, message.speaker, "[uppertext(src.channel_id)]: [message.content] [log_loc(message.speaker)]")
	phrase_log.log_phrase("ooc", message.content)
