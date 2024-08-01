/datum/speech_module/modifier/mutantrace/abomination
	id = SPEECH_MODIFIER_MUTANTRACE_ABOMINATION

/datum/speech_module/modifier/mutantrace/abomination/process(datum/say_message/message)
	. = message

	message.content = pick("We are one...", "Join with us...", "Sssssss...")
