/datum/speech_module/prefix/postmodifier/intercom
	id = SPEECH_PREFIX_INTERCOM
	prefix_id = ":in"

/datum/speech_module/prefix/postmodifier/intercom/process(datum/say_message/message)
	. = message

	if (message.output_module_channel != SAY_CHANNEL_OUTLOUD)
		return

	message.atom_listeners_to_be_excluded ||= list()
	var/list/obj/item/device/radio/intercom/intercoms = list()
	for (var/obj/item/device/radio/intercom/intercom in view(1, message.message_origin))
		message.atom_listeners_to_be_excluded[intercom] = TRUE
		intercoms += intercom

	if (!length(intercoms))
		return

	var/datum/say_message/radio_message = message.Copy()
	radio_message.atom_listeners_override = intercoms
	src.parent_tree.GetOutputByID(SPEECH_OUTPUT_EQUIPPED)?.process(radio_message)

	message.flags |= SAYFLAG_WHISPER
	message.heard_range = WHISPER_EAVESDROPPING_RANGE
	message.say_sound = 'sound/misc/talk/radio.ogg'
