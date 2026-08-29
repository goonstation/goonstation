/datum/speech_module/modifier/monospace_forced
	id = SPEECH_MODIFIER_MONOSPACE_FORCED

/datum/speech_module/modifier/monospace_forced/process(datum/say_message/message)
	. = message
	message.format_content_style_prefix = "<span class='monospace'>"
	message.format_content_style_suffix = "</span>"

