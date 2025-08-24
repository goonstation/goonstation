/datum/speech_module/modifier/mutantrace/amphibian
	id = SPEECH_MODIFIER_MUTANTRACE_AMPHIBIAN

/datum/speech_module/modifier/mutantrace/amphibian/process(datum/say_message/message)
	. = message

	message.content = replacetext(message.content, "r", stutter("rrr"))
