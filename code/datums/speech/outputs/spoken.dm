/datum/speech_module/output/spoken
	id = "spoken"

	process(datum/say_message/message)
		//do atom maptext here or maybe in the equivalent input?
		global.SpeechManager.PassToListeners(message, SAY_CHANNEL_OUTLOUD)
