/datum/speech_module/modifier/inverted_speech
	id = SPEECH_MODIFIER_INVERTED_SPEECH

/datum/speech_module/modifier/inverted_speech/process(datum/say_message/message)
	. = message

	message.format_content_style_prefix = "<span style='-ms-transform: rotate(180deg)'>"
	message.format_content_style_suffix = "</span>"
