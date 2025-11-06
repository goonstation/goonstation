/datum/speech_module/modifier/mutantrace/repeated_letter/cow
	id = SPEECH_MODIFIER_MUTANTRACE_COW
	target_letter = "m"

/datum/speech_module/modifier/mutantrace/repeated_letter/cow/process(datum/say_message/message)
	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(replacetext_wrapper), "cow", "human"))
	. = ..()
