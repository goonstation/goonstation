/datum/message_modifier/postprocessing/no_say_verb
	sayflag = SAYFLAG_NO_SAY_VERB
	priority = SAYFLAG_PRIORITY_PROCESS_LAST

/datum/message_modifier/postprocessing/no_say_verb/process(datum/say_message/message)
	. = message

	message.say_verb = ""
