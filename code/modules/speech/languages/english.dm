/datum/language/english
	id = LANGUAGE_ENGLISH

/datum/language/english/heard_not_understood(datum/say_message/message, datum/listen_module_tree/listen_tree)
	. = ..()

	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(stars)))
