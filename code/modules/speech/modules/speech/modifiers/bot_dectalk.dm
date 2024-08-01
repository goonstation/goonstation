/datum/speech_module/modifier/bot_dectalk
	id = SPEECH_MODIFIER_BOT_DECTALK
	priority = SPEECH_MODIFIER_PRIORITY_PROCESS_LAST

/datum/speech_module/modifier/bot_dectalk/process(datum/say_message/message)
	. = message

	var/obj/machinery/bot/bot = message.speaker
	if (!istype(bot) || !bot.text2speech)
		return

	SPAWN(0)
		var/audio = dectalk("\[:nk\][message.content]", BOTTALK_VOLUME)
		if (!audio || !audio["audio"])
			return

		for (var/mob/M in hearers(message.message_origin, null))
			if (!M.client || (M.client.ignore_sound_flags & (SOUND_VOX | SOUND_ALL)))
				continue

			ehjax.send(M.client, "browseroutput", list("dectalk" = audio["audio"]))
