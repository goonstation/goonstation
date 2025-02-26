/datum/listen_module/effect/buttbot
	id = LISTEN_EFFECT_BUTTBOT

/datum/listen_module/effect/buttbot/process(datum/say_message/message)
	var/obj/machinery/bot/buttbot/bot = src.parent_tree.listener_parent
	if (!istype(bot) || !bot.on || !ismob(message.speaker))
		return

	bot.butt_memory |= message.content
