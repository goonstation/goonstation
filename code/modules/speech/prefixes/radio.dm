/datum/say_prefix/radio
	id = list(";", ":")

/datum/say_prefix/radio/process(datum/say_message/message, datum/speech_module_tree/say_tree)
	. = message

	var/mob/mob_speaker = message.message_origin
	var/obj/item/device/radio/radio = mob_speaker.find_radio()
	if (!radio)
		return

	message.atom_listeners_to_be_excluded ||= list()
	message.atom_listeners_to_be_excluded[radio] = TRUE

	var/datum/say_message/radio_message = message.Copy()
	radio_message.atom_listeners_override = list(radio)
	say_tree.GetOutputByID(SPEECH_OUTPUT_EQUIPPED)?.process(radio_message)
