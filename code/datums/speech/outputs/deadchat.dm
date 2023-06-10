TYPEINFO(/datum/speech_module/output/deadchat)
	id = "deadchat"
/datum/speech_module/output/deadchat
	id = "deadchat"
	channel = SAY_CHANNEL_DEAD

	process(datum/say_message/message)
		if (!deadchat_allowed)
			boutput(message.speaker, "<b>Deadchat is currently disabled.</b>")
			return null

		logTheThing(LOG_DIARY, message.speaker, "(GHOST): [message.content]", "say")
		phrase_log.log_phrase("deadsay", message.content)
#ifdef DATALOGGER
		game_stats.ScanText(message.content)
#endif

		//oscillate_colors(chat_text, list(maptext_color, "#c482d1"))
		//TODO implement oscillating maptext colour
		. = ..()
