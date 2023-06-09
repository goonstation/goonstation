TYPEINFO(/datum/speech_module/output/deadchat)
	id = "deadchat"
/datum/speech_module/output/deadchat
	id = "deadchat"
	channel = SAY_CHANNEL_DEAD

	process(datum/say_message/message)
		. = ..()
