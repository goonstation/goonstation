/datum/speech_module/prefix/intercom
	id = SPEECH_PREFIX_INTERCOM
	prefix_id = ":in"

/datum/speech_module/prefix/intercom/process(datum/say_message/message)
	. = message

	message.atom_listeners_to_be_excluded ||= list()
	var/list/obj/item/device/radio/intercom/intercoms = list()
	for (var/obj/item/device/radio/intercom/intercom in view(1, message.message_origin))
		message.atom_listeners_to_be_excluded[intercom] = TRUE
		intercoms += intercom

	if (!length(intercoms))
		return

	message.say_sound = 'sound/misc/talk/radio.ogg'

	var/datum/say_message/radio_message = message.Copy()
	radio_message.atom_listeners_override = intercoms
	src.parent_tree.GetOutputByID(SPEECH_OUTPUT_EQUIPPED)?.process(radio_message)

	message.flags |= SAYFLAG_WHISPER
