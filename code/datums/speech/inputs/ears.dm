TYPEINFO(/datum/listen_module/input/ears)
	id = "ears"
/datum/listen_module/input/ears
	id = "ears"
	channel = SAY_CHANNEL_OUTLOUD

	process(datum/say_message/message)
		if(message.heard_range == 0)
			if(src.parent_tree.parent == message.speaker.loc) //range 0 means it's only audible if it's from inside you (ie radios, direct messages)
				. = ..()
		else if(src.parent_tree.parent in hearers(message.speaker, message.heard_range)) //This isn't optimised in BYOND, hopefully it can be in OD
			. = ..()
