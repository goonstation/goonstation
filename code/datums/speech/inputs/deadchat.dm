TYPEINFO(/datum/listen_module/input/deadchat)
	id = "deadchat"
/datum/listen_module/input/deadchat
	id = "deadchat"
	channel = SAY_CHANNEL_DEAD

	process(datum/say_message/message)
		. = ..()
