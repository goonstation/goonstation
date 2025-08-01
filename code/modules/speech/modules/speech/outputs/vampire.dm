/datum/speech_module/modifier/vampire
	id = SPEECH_MODIFIER_VAMPIRE

/datum/speech_module/modifier/vampire/process(datum/say_message/message)
	. = message
	message.maptext_css_values["font-family"] = "'Old London'"
	message.maptext_css_values["font-size"] = "10px"
