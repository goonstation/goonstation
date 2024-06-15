/datum/speech_module/output/equipped
	id = SPEECH_OUTPUT_EQUIPPED
	channel = SAY_CHANNEL_EQUIPPED

/datum/speech_module/output/equipped/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT

	. = ..()
