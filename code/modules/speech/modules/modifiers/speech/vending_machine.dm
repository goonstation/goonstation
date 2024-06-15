/datum/speech_module/modifier/vending_machine
	id = SPEECH_MODIFIER_VENDING_MACHINE

/datum/speech_module/modifier/vending_machine/process(datum/say_message/message)
	. = message

	var/obj/machinery/vending/vending_machine = message.speaker
	if (!istype(vending_machine))
		return

	message.maptext_css_values["color"] = vending_machine.slogan_text_color
	message.maptext_variables["alpha"] = vending_machine.slogan_text_alpha
