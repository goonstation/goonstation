/datum/speech_module/modifier/monospace_decorator
	id = SPEECH_MODIFIER_MONOSPACE_DECORATOR
	var/static/regex/monospace_regex = new(@"`([^`]+)`", "g")
	var/static/monospace_replacement = "[MAKE_CONTENT_IMMUTABLE("<span class='monospace'>")]$1[MAKE_CONTENT_IMMUTABLE("</span>")]"
	var/static/normal_replacement = "[MAKE_CONTENT_IMMUTABLE("</span>")]$1[MAKE_CONTENT_IMMUTABLE("<span class='monospace'>")]"
	var/inverted = FALSE

/datum/speech_module/modifier/monospace_decorator/process(datum/say_message/message)
	. = message
	if(src.inverted)
		message.content = src.monospace_regex.Replace(message.content, src.normal_replacement)
		message.content = SPAN_MONOSPACE(message.content)
	else
		message.content = src.monospace_regex.Replace(message.content, src.monospace_replacement)
