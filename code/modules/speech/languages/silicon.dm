/datum/language/silicon
	id = LANGUAGE_SILICON

/datum/language/silicon/heard_not_understood(datum/say_message/message, datum/listen_module_tree/listen_tree)
	. = ..()

	message.content = MAKE_CONTENT_MUTABLE("beep beep beep")
