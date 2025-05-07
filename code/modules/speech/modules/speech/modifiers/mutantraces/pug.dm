/datum/speech_module/modifier/mutantrace/pug
	id = SPEECH_MODIFIER_MUTANTRACE_PUG

/datum/speech_module/modifier/mutantrace/pug/process(datum/say_message/message)
	. = message

	message.content = replacetext(message.content, "rough", "ruff")
	message.content = replacetext(message.content, "pog", "pug")
