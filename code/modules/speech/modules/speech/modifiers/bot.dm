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
			var/list/word_list = splittext(message.content, " ")
			var/length = length(word_list)

			if (length <= 1)
				return

			var/stutter_point = rand(round(length / 2), length)
			word_list.len = stutter_point
			message.content = jointext(word_list, " ")

			for (var/i in 1 to rand(1, 3))
				message.content += "-[uppertext(word_list[stutter_point])]"

		if (2)
			var/list/word_list = splittext(message.content, " ")
			var/length = length(word_list)

			if (length <= 1)
				return

			for (var/i in 1 to length)
				if (!prob(min(5 * i, 20)))
					continue

				word_list[i] = pick("*BZZT*","*ERRT*","*WONK*", "*ZORT*", "*BWOP*", "BWEET")

			message.content = jointext(word_list, " ")

		if (3)
			message.speaker.visible_message("<span class='combat'><b>[message.speaker]'s speaker crackles oddly!</b></span>")
			return NO_MESSAGE

		if (4)
			message.content = uppertext(message.content)

		else // This is default behaviour, but is required to suppress a missing branches warning.
			return


/datum/speech_module/modifier/bot/bootleg
	id = SPEECH_MODIFIER_BOT_BOOTLEG

/datum/speech_module/modifier/bot/bootleg/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	message.content = uppertext(message.content)
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
			message.content = pick("WACKA", "QUACK","QUACKY","GAGGLE")

	message.format_content_style_prefix = "<font face='[font]'>"
	message.format_content_style_suffix = "</font>"
	message.content = "[message.content]!!"


/datum/speech_module/modifier/bot/chef
	id = SPEECH_MODIFIER_BOT_CHEF

/datum/speech_module/modifier/bot/chef/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	message.content = uppertext(message.content)


/datum/speech_module/modifier/bot/old
	id = SPEECH_MODIFIER_BOT_OLD

/datum/speech_module/modifier/bot/old/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	message.content = uppertext(message.content)
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
		message.content = capitalize(ckeyEx(message.content))


/datum/speech_module/modifier/bot/soviet
	id = SPEECH_MODIFIER_BOT_SOVIET

/datum/speech_module/modifier/bot/soviet/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	message.content = uppertext(message.content)
	message.format_content_style_prefix = "<font face='Curlz MT'>"
	message.format_content_style_suffix = "</font>"


/datum/speech_module/modifier/bot/xmas
	id = SPEECH_MODIFIER_BOT_XMAS

/datum/speech_module/modifier/bot/xmas/process(datum/say_message/message)
	. = ..()
	if (!.)
		return

	message.content = uppertext(message.content)
	message.format_content_style_prefix = "<font face='Segoe Script'><i><b>"
	message.format_content_style_suffix = "</b></i></font>"
