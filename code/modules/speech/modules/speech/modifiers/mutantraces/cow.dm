/datum/speech_module/modifier/mutantrace/cow
	id = SPEECH_MODIFIER_MUTANTRACE_COW

/datum/speech_module/modifier/mutantrace/cow/process(datum/say_message/message)
	. = message

	message.content = replacetext(message.content, "cow", "human")
	message.content = replacetextEx(message.content, "m", stutter("mm"))
	message.content = replacetextEx(message.content, "M", stutter("MM"))
