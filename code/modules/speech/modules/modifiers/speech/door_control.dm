/datum/speech_module/modifier/door_control
	id = SPEECH_MODIFIER_DOOR_CONTROL

/datum/speech_module/modifier/door_control/process(datum/say_message/message)
	. = message

	var/obj/machinery/door_control/door_control = message.speaker
	if (!istype(door_control))
		return

	message.maptext_css_values["color"] = door_control.welcome_text_color
	message.maptext_variables["alpha"] = door_control.welcome_text_alpha
