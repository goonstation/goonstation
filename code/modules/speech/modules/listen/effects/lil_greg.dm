/datum/listen_module/effect/lil_greg
	id = LISTEN_EFFECT_LIL_GREG

/datum/listen_module/effect/lil_greg/process(datum/say_message/message)
	var/obj/item/lilgreg/greg = src.parent_tree.listener_parent
	if (!istype(greg) || !ismob(message.speaker) || !message.can_relay || prob(90))
		return

	SPAWN(0)
		var/adjective = pick("radical", "awesome", "sweet", "delicious", "100% spectacular", "better then sliced bread", "hootacular", "horrible", "hootastic", "dab worthy")
		greg.say("Woah [message.speaker] that's [adjective]!", message_params = list("can_relay" = FALSE))
