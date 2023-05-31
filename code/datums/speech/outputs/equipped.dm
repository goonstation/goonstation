TYPEINFO(/datum/speech_module/output/equipped)
	id = "equipped"
/datum/speech_module/output/equipped
	id = "equipped"
	channel = SAY_CHANNEL_EQUIPPED

	process(datum/say_message/message)
		. = ..()
