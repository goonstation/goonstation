TYPEINFO(/datum/listen_module/input/equipped)
	id = "equipped"
/datum/listen_module/input/equipped
	id = "equipped"
	channel = SAY_CHANNEL_EQUIPPED
	/// The prefix that this equippment should listen for. Leave null to hear all messages. Examples include ":rh" for objects in the right hand, ";" for radios in the ear. Can be a list of values.
	var/my_prefix = null

	process(datum/say_message/message)
		if(src.parent_tree.parent.loc != message.speaker) //TODO nested locs?
			return
		if(src.my_prefix == null || message.prefix == src.my_prefix || (islist(src.my_prefix) && (message.prefix in src.my_prefix)))
			. = ..()
