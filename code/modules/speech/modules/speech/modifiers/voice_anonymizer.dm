/datum/speech_module/modifier/voice_anonymizer
	id = SPEECH_MODIFIER_VOICE_ANONYMIZER

/datum/speech_module/modifier/voice_anonymizer/process(datum/say_message/message)
	. = message
	message.speaker_to_display = "Unknown"
	message.content = "[MAKE_CONTENT_IMMUTABLE("<span class='monospace'>")][message.content][MAKE_CONTENT_IMMUTABLE("</span>")]"
