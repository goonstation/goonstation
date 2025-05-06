/datum/listen_module/effect/skullbot
	id = LISTEN_EFFECT_SKULLBOT

/datum/listen_module/effect/skullbot/process(datum/say_message/message)
	var/obj/machinery/bot/skullbot/bot = src.parent_tree.listener_parent
	if (!istype(bot) || !bot.on || !ismob(message.speaker) || !message.can_relay || prob(75))
		return

	SPAWN(0)
		bot.say(message.content, flags = 0, message_params = list("can_relay" = FALSE))
