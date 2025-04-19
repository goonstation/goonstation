/datum/language/english
	id = LANGUAGE_ENGLISH

/datum/language/english/heard_not_understood(datum/say_message/message, datum/listen_module_tree/listen_tree)
	. = ..()

	message.content = stars(message.content)
