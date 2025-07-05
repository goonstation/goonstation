/datum/say_channel/delimited/local/equipped
	channel_id = SAY_CHANNEL_EQUIPPED
	listener_tick_cache_type = /datum/listener_tick_cache/origin_dependent

/datum/say_channel/delimited/local/equipped/PassToChannel(datum/say_message/message)
	var/list/list/datum/listen_module/input/listen_modules_by_type = src.listener_tick_cache.read_from_cache(message)
	if (islist(listen_modules_by_type))
		src.PassToListeners(message, listen_modules_by_type)
		return

	listen_modules_by_type = list()

	for (var/type in src.listeners)
		listen_modules_by_type[type] ||= list()
		for (var/datum/listen_module/input/input as anything in src.listeners[type])
			// Determine whether the message can be heard based on a shared loc chain.
			if (CANNOT_HEAR_MESSAGE_FROM_LOC_CHAIN(input, message))
				continue

			listen_modules_by_type[type] += input

	src.listener_tick_cache.write_to_cache(message, listen_modules_by_type)
	src.PassToListeners(message, listen_modules_by_type)

/datum/say_channel/delimited/local/equipped/log_message()
	return
