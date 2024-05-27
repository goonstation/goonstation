/datum/listen_module/input/equipped
	id = LISTEN_INPUT_EQUIPPED
	channel = SAY_CHANNEL_EQUIPPED
	/// The prefix that this equippment should listen for. Leave null to hear all messages. Examples include ":rh" for objects in the right hand, ";" for radios in the ear. Can be a list of values.
	var/my_prefix

/datum/listen_module/input/equipped/process(datum/say_message/message)
	if (isnull(src.my_prefix) || (message.prefix == src.my_prefix) || (islist(src.my_prefix) && (message.prefix in src.my_prefix)))
		. = ..()
