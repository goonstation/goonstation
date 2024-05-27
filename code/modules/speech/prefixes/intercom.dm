/datum/say_prefix/intercom
	id = ":in"

/datum/say_prefix/intercom/is_compatible_with(datum/say_message/message, datum/speech_module_tree/say_tree)
	return TRUE

/datum/say_prefix/intercom/process(datum/say_message/message, datum/speech_module_tree/say_tree)
	. = message

	message.atom_listeners_to_be_excluded ||= list()
	var/list/obj/item/device/radio/intercom/intercoms = list()
	for (var/obj/item/device/radio/intercom/intercom in view(1, message.speaker))
		message.atom_listeners_to_be_excluded[intercom] = TRUE
		intercoms += intercom

	if (!length(intercoms))
		return

	var/datum/say_message/radio_message = message.Copy()
	radio_message.atom_listeners_override = intercoms
	say_tree.GetOutputByID(SPEECH_OUTPUT_EQUIPPED)?.process(radio_message)
