/datum/speech_module/modifier/megaphone
	id = SPEECH_MODIFIER_MEGAPHONE

/datum/speech_module/modifier/megaphone/process(datum/say_message/message)
	. = message

	if (!ismob(message.message_origin))
		return

	var/mob/mob_speaker = message.message_origin
	var/obj/item/megaphone/megaphone = mob_speaker.find_type_in_hand(/obj/item/megaphone)

	if (!megaphone)
		return

	message.maptext_css_values["font-family"] = ((megaphone.maptext_size >= 12) ? "'PxPlus IBM VGA9'" : "'Small Fonts'")
	message.maptext_css_values["font-weight"] = "bold"
	message.maptext_css_values["font-size"] = "[megaphone.maptext_size]px"
	message.maptext_css_values["color"] = megaphone.maptext_color
	message.maptext_css_values["-dm-text-outline"] = "1px [megaphone.maptext_outline_color]"

	message.maptext_variables["maptext_height"] *= 4
	message.maptext_variables["maptext_width"] *= 2
	message.maptext_variables["maptext_x"] = (message.maptext_variables["maptext_x"] * 2) - 16

	message.loudness += megaphone.loudness_mod
