/datum/speech_module/modifier/monospace_decorator
	id = SPEECH_MODIFIER_MONOSPACE_DECORATOR
	var/static/regex/monospace_regex = new(@"`([^`]+)`", "g")
	var/static/monospace_replacement = "[MAKE_CONTENT_IMMUTABLE("<span class='monospace'>")]$1[MAKE_CONTENT_IMMUTABLE("</span>")]"

/datum/speech_module/modifier/monospace_decorator/process(datum/say_message/message)
	. = message

	message.content = src.monospace_regex.Replace(message.content, src.monospace_replacement)
