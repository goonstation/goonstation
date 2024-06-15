/datum/message_modifier/postprocessing/whisper
	sayflag = SAYFLAG_WHISPER

/datum/message_modifier/postprocessing/whisper/process(datum/say_message/message)
	. = message

	message.flags |= SAYFLAG_NO_MAPTEXT
	message.say_verb = message.whisper_verb
	message.content = "<i>[message.content]</i>"
