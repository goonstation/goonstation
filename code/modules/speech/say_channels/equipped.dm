/datum/say_channel/delimited/local/equipped
	channel_id = SAY_CHANNEL_EQUIPPED

/datum/say_channel/delimited/local/equipped/PassToChannel(datum/say_message/message)
	var/list/list/datum/listen_module/input/listen_modules_by_type = list()

	for (var/type in src.listeners)
		listen_modules_by_type[type] ||= list()
		for (var/datum/listen_module/input/input as anything in src.listeners[type])
			// If the outermost listener of the listener and the speaker match, the listener may hear the message.
			if (GET_INPUT_OUTERMOST_LISTENER(input) != GET_MESSAGE_OUTERMOST_LISTENER(message))
				// If the outermost listener's loc is the speaker, the listener may hear the message.
				if (GET_INPUT_OUTERMOST_LISTENER_LOC(input) != message.message_origin)
					// If the speaker's loc is the listener, the listener may hear the message.
					if (message.message_origin.loc != input.parent_tree.listener_origin)
						continue

			listen_modules_by_type[type] += input

	src.PassToListeners(message, listen_modules_by_type)
