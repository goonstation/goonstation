/datum/speech_module/modifier/inverted_speech
	id = SPEECH_MODIFIER_INVERTED_SPEECH

/datum/speech_module/modifier/inverted_speech/process(datum/say_message/message)
	message.content = "<span style='-ms-transform: rotate(180deg)'>[message.content]</span>"
	. = message
