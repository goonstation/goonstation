/datum/speech_module/modifier/mutantrace/pug
	id = SPEECH_MODIFIER_MUTANTRACE_PUG

/datum/speech_module/modifier/mutantrace/pug/process(datum/say_message/message)
	. = message

	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(replacetext_wrapper), "rough", "ruff"))
	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(replacetext_wrapper), "pog", "pug"))
