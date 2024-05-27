/datum/listen_module/input/looc
	id = LISTEN_INPUT_LOOC
	channel = SAY_CHANNEL_LOOC


/datum/listen_module/input/looc/admin
	id = LISTEN_INPUT_LOOC_ADMIN
	channel = SAY_CHANNEL_GLOBAL_LOOC

/datum/listen_module/input/looc/admin/process(datum/say_message/message)
	if (ismob(src.parent_tree.parent))
		var/mob/mob_listener = src.parent_tree.parent

		// If global LOOC is disabled, don't receive the message if the message is heard from outside of LOOC range.
		if ((!mob_listener.client.only_local_looc || mob_listener.client.player_mode) && !IN_RANGE(mob_listener, message.speaker, LOOC_RANGE))
			return

	. = ..()
