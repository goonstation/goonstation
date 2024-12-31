/datum/speech_module/modifier/mutantrace/zombie
	id = SPEECH_MODIFIER_MUTANTRACE_ZOMBIE

/datum/speech_module/modifier/mutantrace/zombie/process(datum/say_message/message)
	. = message

	message.content = pick("Urgh...", "Brains...", "Hungry...", "Kill...")
