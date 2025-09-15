/datum/speech_module/modifier/bot
	id = SPEECH_MODIFIER_BOT
	priority = SPEECH_MODIFIER_PRIORITY_VERY_LOW

/datum/speech_module/modifier/bot/process(datum/say_message/message)
	var/obj/machinery/bot/bot = message.speaker
	if (!istype(bot) || !bot.on || bot.muted)
		return NO_MESSAGE

	. = message
	message.maptext_css_values["color"] = bot.bot_speech_color


/datum/speech_module/modifier/bot/bad
	id = SPEECH_MODIFIER_BOT_BAD

/datum/speech_module/modifier/bot/bad/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	switch (rand(1, 10))
		if (1)
			APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(src, PROC_REF(stutter_text)))

		if (2)
			APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(src, PROC_REF(corrupt_text)))

		if (3)
			APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(uppertext_wrapper)))

		if (4)
			message.speaker.visible_message("<span class='combat'><b>[message.speaker]'s speaker crackles oddly!</b></span>")
			return NO_MESSAGE

		else // This is default behaviour, but is required to suppress a missing branches warning.
			return

/datum/speech_module/modifier/bot/bad/proc/stutter_text(string)
	var/list/word_list = splittext(string, " ")
	var/length = length(word_list)

	if (length <= 1)
		return

	var/stutter_point = rand(round(length / 2), length)
	word_list.len = stutter_point
	string = jointext(word_list, " ")

	for (var/i in 1 to rand(1, 3))
		string += "-[uppertext(word_list[stutter_point])]"

	return string

/datum/speech_module/modifier/bot/bad/proc/corrupt_text(string)
	var/list/word_list = splittext(string, " ")
	var/length = length(word_list)

	if (length <= 1)
		return

	for (var/i in 1 to length)
		if (!prob(min(5 * i, 20)))
			continue

		word_list[i] = pick("*BZZT*","*ERRT*","*WONK*", "*ZORT*", "*BWOP*", "BWEET")

	return jointext(word_list, " ")


/datum/speech_module/modifier/bot/bootleg
	id = SPEECH_MODIFIER_BOT_BOOTLEG

/datum/speech_module/modifier/bot/bootleg/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(uppertext_wrapper)))
	message.message_size_override = 3

	var/font = ""
	switch (rand(1, 4))
		if (1)
			font = "Comic Sans MS"
		if (2)
			font = "Curlz MT"
		if (3)
			font = "System"
		else
			if (!ON_COOLDOWN(message.speaker, "bootleg_sound", 15 SECONDS))
				playsound(message.speaker.loc, 'sound/misc/amusingduck.ogg', 50, 0)

			font = "Comic Sans MS"
			message.content = MAKE_CONTENT_MUTABLE(pick("WACKA", "QUACK","QUACKY","GAGGLE"))

	message.format_content_style_prefix = "<font face='[font]'>"
	message.format_content_style_suffix = "</font>"
	message.content += MAKE_CONTENT_MUTABLE("!!")


/datum/speech_module/modifier/bot/chef
	id = SPEECH_MODIFIER_BOT_CHEF

/datum/speech_module/modifier/bot/chef/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(uppertext_wrapper)))


/datum/speech_module/modifier/bot/old
	id = SPEECH_MODIFIER_BOT_OLD

/datum/speech_module/modifier/bot/old/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(uppertext_wrapper)))
	message.format_content_style_prefix = "<span style=\"font-family: 'Consolas', monospace;\">"
	message.format_content_style_suffix = "</span>"


/datum/speech_module/modifier/bot/secbot
	id = SPEECH_MODIFIER_BOT_SECURITY

/datum/speech_module/modifier/bot/secbot/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	var/obj/machinery/bot/secbot/bot = message.speaker
	if (bot.emagged >= 2)
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(ckeyEx_wrapper)))
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(capitalize)))


/datum/speech_module/modifier/bot/soviet
	id = SPEECH_MODIFIER_BOT_SOVIET

/datum/speech_module/modifier/bot/soviet/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(uppertext_wrapper)))
	message.format_content_style_prefix = "<font face='Curlz MT'>"
	message.format_content_style_suffix = "</font>"


/datum/speech_module/modifier/bot/xmas
	id = SPEECH_MODIFIER_BOT_XMAS

/datum/speech_module/modifier/bot/xmas/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(uppertext_wrapper)))
	message.format_content_style_prefix = "<font face='Segoe Script'><i><b>"
	message.format_content_style_suffix = "</b></i></font>"
