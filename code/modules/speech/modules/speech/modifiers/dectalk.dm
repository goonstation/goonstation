/datum/speech_module/modifier/dectalk
	id = "dectalk_parent"
	priority = SPEECH_MODIFIER_PRIORITY_PROCESS_LAST

/datum/speech_module/modifier/dectalk/process(datum/say_message/message)
	. = message

	if (!src.can_use_dectalk(message))
		return

	SPAWN(0)
		var/audio = dectalk("\[:nk\][STRIP_IMMUTABLE_CONTENT(message.content)]", BOTTALK_VOLUME)
		if (!audio || !audio["audio"])
			return

		for (var/mob/M in hearers(message.message_origin, null))
			if (!M.client || (M.client.ignore_sound_flags & (SOUND_VOX | SOUND_ALL)))
				continue

			ehjax.send(M.client, "browseroutput", list("dectalk" = audio["audio"]))

/datum/speech_module/modifier/dectalk/proc/can_use_dectalk(datum/say_message/message)
	return TRUE


/datum/speech_module/modifier/dectalk/bot
	id = SPEECH_MODIFIER_DECTALK_BOT

/datum/speech_module/modifier/dectalk/bot/can_use_dectalk(datum/say_message/message)
	var/obj/machinery/bot/bot = message.speaker
	if (!istype(bot) || !bot.text2speech)
		return FALSE

	return TRUE


/datum/speech_module/modifier/dectalk/head_surgeon
	id = SPEECH_MODIFIER_DECTALK_HEAD_SURGEON

/datum/speech_module/modifier/dectalk/head_surgeon/can_use_dectalk(datum/say_message/message)
	var/obj/item/clothing/suit/cardboard_box/head_surgeon/head_surgeon = message.speaker
	if (!istype(head_surgeon) || !head_surgeon.text2speech)
		return FALSE

	return TRUE
