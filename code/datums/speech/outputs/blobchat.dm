TYPEINFO(/datum/speech_module/output/blobchat)
	id = "blobchat"
/datum/speech_module/output/blobchat
	id = "blobchat"
	channel = SAY_CHANNEL_BLOB

	process(datum/say_message/message)
		logTheThing(LOG_DIARY, message.speaker, "(BLOB): [message.content]", "say")
		phrase_log.log_phrase("say", message.content)
#ifdef DATALOGGER
		game_stats.ScanText(message.content)
#endif

		. = ..()
