/datum/speech_module/prefix/radio
	id = SPEECH_PREFIX_RADIO
	prefix_id = list(";", ":")

/datum/speech_module/prefix/radio/process(datum/say_message/message)
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
	src.parent_tree.GetOutputByID(SPEECH_OUTPUT_EQUIPPED)?.process(radio_message)

	message.flags |= SAYFLAG_WHISPER
