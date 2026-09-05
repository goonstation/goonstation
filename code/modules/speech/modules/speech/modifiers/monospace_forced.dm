/datum/speech_module/modifier/monospace_forced
	id = SPEECH_MODIFIER_MONOSPACE_FORCED
	var/static/regex/monospace_regex = new(@"`([^`]+)`", "g")
	var/static/normal_replacement = "[MAKE_CONTENT_IMMUTABLE("</span>")]$1[MAKE_CONTENT_IMMUTABLE("<span class='monospace'>")]"

/datum/speech_module/modifier/monospace_forced/process(datum/say_message/message)
	. = message

	message.content = src.monospace_regex.Replace(message.content, src.normal_replacement)
	message.content = SPAN_MONOSPACE(message.content)
// We don't do format_content_style_prefix or suffix because it doesn't play nicely with our weird inverted spans

