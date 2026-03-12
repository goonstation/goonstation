/datum/language/monkey
	id = LANGUAGE_MONKEY

/datum/language/monkey/heard_not_understood(datum/say_message/message, datum/listen_module_tree/listen_tree)
	. = ..()

	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS
	message.say_verb = "chimpers"
	message.content = ""
	message.format_content_prefix = "."
