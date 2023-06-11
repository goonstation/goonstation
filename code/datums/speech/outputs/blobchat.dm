TYPEINFO(/datum/speech_module/output/blobchat)
	id = "blobchat"
/datum/speech_module/output/blobchat
	id = "blobchat"
	channel = SAY_CHANNEL_BLOB

	process(datum/say_message/message)
		logTheThing(LOG_DIARY, message.speaker, "(GHOST): [message.content]", "say")
		phrase_log.log_phrase("deadsay", message.content)
#ifdef DATALOGGER
		game_stats.ScanText(message.content)
#endif

		. = ..()
