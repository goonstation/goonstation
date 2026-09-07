/datum/speech_module/modifier/monospace_decorator
	id = SPEECH_MODIFIER_MONOSPACE_DECORATOR
	var/static/regex/monospace_regex = new(@"`([^`]+)`", "g")
	var/static/monospace_replacement = "[MAKE_CONTENT_IMMUTABLE("<span class='monospace'>")]$1[MAKE_CONTENT_IMMUTABLE("</span>")]"
	var/static/normal_replacement = "[MAKE_CONTENT_IMMUTABLE("</span>")]$1[MAKE_CONTENT_IMMUTABLE("<span class='monospace'>")]"
	var/inverted = FALSE

/datum/speech_module/modifier/monospace_decorator/process(datum/say_message/message)
	. = message
	message.content = src.monospace_regex.Replace(message.content, src.inverted ? src.normal_replacement : src.monospace_replacement)
	if(inverted)
		message.content = SPAN_MONOSPACE(message.content)
// We don't do format_content_style_prefix or suffix because it doesn't play nicely with our weird inverted spans

/datum/speech_module/modifier/monospace_decorator/inverted
	id = SPEECH_MODIFIER_MONOSPACE_DECORATOR_INVERTED
	inverted = TRUE
