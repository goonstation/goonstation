/datum/speech_module/modifier/radio
	id = SPEECH_MODIFIER_RADIO

/datum/speech_module/modifier/radio/process(datum/say_message/message)
	. = message

	var/obj/item/device/radio/radio = message.speaker
	if (!istype(radio))
		return

	if (!radio.forced_maptext && !global.force_radio_maptext)
		message.flags |= SAYFLAG_NO_MAPTEXT
		return

	message.flags &= ~SAYFLAG_NO_MAPTEXT
	message.maptext_css_values["color"] = radio.device_color
	message.maptext_variables["alpha"] = 140


/datum/speech_module/modifier/radio/intercom
	id = SPEECH_MODIFIER_INTERCOM

/datum/speech_module/modifier/radio/intercom/process(datum/say_message/message)
	. = message

	var/obj/item/device/radio/intercom/intercom = message.speaker
	if (!istype(intercom))
		return

	var/AI_speaker = isAI(message.original_speaker)
	if ((!intercom.forced_maptext && !AI_speaker) || (intercom.frequency == R_FREQ_DEFAULT))
		return ..()

	message.flags &= ~SAYFLAG_NO_MAPTEXT

	if (AI_speaker)
		message.maptext_css_values["color"] = "#7F7FE2"
	else
		message.maptext_css_values["color"] ||= intercom.device_color
