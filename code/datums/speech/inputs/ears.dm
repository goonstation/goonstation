TYPEINFO(/datum/listen_module/input/ears)
	id = "ears"
/datum/listen_module/input/ears
	id = "ears"
	channel = SAY_CHANNEL_OUTLOUD

	process(datum/say_message/message)
		if(src.parent_tree.parent in hearers(message.speaker, message.heard_range)) //This isn't optimised in BYOND, hopefully it can be in OD
			. = ..()
