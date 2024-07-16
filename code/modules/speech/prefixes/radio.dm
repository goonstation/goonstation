/datum/say_prefix/radio
	id = list(";", ":")

/datum/say_prefix/radio/is_compatible_with(datum/say_message/message, datum/speech_module_tree/say_tree)
	. = FALSE

	if (ismob(message.message_origin))
		return TRUE

	if (istype(message.message_origin, /obj/item/organ/head))
		return TRUE

/datum/say_prefix/radio/process(datum/say_message/message, datum/speech_module_tree/say_tree)
	. = message

	var/obj/item/device/radio/radio

	if (ismob(message.message_origin))
		var/mob/mob_speaker = message.message_origin
		radio = mob_speaker.find_radio()
	else
		var/obj/item/organ/head/head = message.message_origin
		radio = head.ears

	if (!istype(radio))
		return

	message.say_sound = 'sound/misc/talk/radio.ogg'
	message.atom_listeners_to_be_excluded ||= list()
	message.atom_listeners_to_be_excluded[radio] = TRUE

	var/datum/say_message/radio_message = message.Copy()
	radio_message.atom_listeners_override = list(radio)
	say_tree.GetOutputByID(SPEECH_OUTPUT_EQUIPPED)?.process(radio_message)
