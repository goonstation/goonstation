/datum/speech_module/modifier/cryptid_plushie
	id = SPEECH_MODIFIER_CRYPTID_PLUSHIE

/datum/speech_module/modifier/cryptid_plushie/process(datum/say_message/message)
	. = message

	message.maptext_css_values["font-style"] = "italic"
	message.maptext_css_values["font-family"] = "'XFont 6x9'"
	message.maptext_css_values["font-size"] = "7px"

	if (prob(20))
		message.maptext_css_values["color"] = "red !important"
