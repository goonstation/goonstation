TYPEINFO(/datum/speech_module/output/hivechat)
	id = "hivechat"
/datum/speech_module/output/hivechat
	id = "hivechat"
	channel = SAY_CHANNEL_HIVEMIND

	process(datum/say_message/message)
		. = TRUE //Always consume the message here. If it's for hivechat, it's not for anything else.
		logTheThing(LOG_DIARY, message.speaker, "(HIVEMIND): [message.content]", "say")
		phrase_log.log_phrase("say", message.content)
#ifdef DATALOGGER
		game_stats.ScanText(message.content)
#endif
