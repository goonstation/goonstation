TYPEINFO(/datum/speech_module/output/spoken)
	id = "spoken"
/datum/speech_module/output/spoken
	id = "spoken"
	channel = SAY_CHANNEL_OUTLOUD

	process(datum/say_message/message)
		//do atom maptext here or maybe in the equivalent input?
		. = ..()

