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
		message.say_verb = pick("moans","wails","laments")
		if (prob(5))
			message.say_verb = "grumps"
		message.maptext_animation_colors = list("start_color", "#c482d1")
		. = ..()
