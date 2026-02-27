/datum/listen_module/modifier/comic_sans
	id = LISTEN_MODIFIER_COMIC_SANS

/datum/listen_module/modifier/comic_sans/process(datum/say_message/message)
	message.format_content_style_prefix = "<font face='Comic Sans MS'>"
	message.format_content_style_suffix = "</font>"
	message.maptext_css_values["font-size"] = "8px"
	. = message
