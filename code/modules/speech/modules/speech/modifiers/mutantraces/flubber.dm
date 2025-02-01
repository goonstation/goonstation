/datum/speech_module/modifier/mutantrace/flubber
	id = SPEECH_MODIFIER_MUTANTRACE_FLUBBER

/datum/speech_module/modifier/mutantrace/flubber/process(datum/say_message/message)
	. = message

	message.content = pick("Wooo!!", "Whopeee!!", "Boing!!", "Čapaš!!")
