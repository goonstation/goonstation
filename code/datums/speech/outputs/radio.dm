TYPEINFO(/datum/speech_module/output/radio)
	id = "radio"
/datum/speech_module/output/radio
	id = "radio"
	channel = SAY_CHANNEL_RADIO_PREFIX+"none"

	process(datum/say_message/message)
		//do atom maptext here or maybe in the equivalent input?
		. = ..()
