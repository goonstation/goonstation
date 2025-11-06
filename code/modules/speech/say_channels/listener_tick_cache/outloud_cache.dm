/datum/listener_tick_cache/outloud

/datum/listener_tick_cache/outloud/write_to_cache(datum/say_message/message, list/list/datum/listen_module/input/listeners, heard_clearly)
	if (src.cache_tick != world.time)
		src.cached_listeners_by_range_message_origin = null

	src.cache_tick = world.time

	var/use_range_check = isturf(GET_MESSAGE_OUTERMOST_LISTENER_LOC(message))
	var/flags = "[(use_range_check << 0) | ((message.flags & SAYFLAG_WHISPER) << 1) | (heard_clearly << 2)]"
	src.cached_listeners_by_range_message_origin ||= list()
	src.cached_listeners_by_range_message_origin[message.message_origin] ||= list()

	if (use_range_check)
		src.cached_listeners_by_range_message_origin[message.message_origin][flags] ||= list()
		src.cached_listeners_by_range_message_origin[message.message_origin][flags]["[message.heard_range]"] = listeners
	else
		src.cached_listeners_by_range_message_origin[message.message_origin][flags] = listeners

/datum/listener_tick_cache/outloud/read_from_cache(datum/say_message/message, heard_clearly)
	RETURN_TYPE(/list/list/datum/listen_module/input)

	if (!src.cached_listeners_by_range_message_origin || !src.cached_listeners_by_range_message_origin[message.message_origin])
		return

	if (src.cache_tick != world.time)
		src.cached_listeners_by_range_message_origin = null
		return

	var/use_range_check = isturf(GET_MESSAGE_OUTERMOST_LISTENER_LOC(message))
	var/flags = "[(use_range_check << 0) | ((message.flags & SAYFLAG_WHISPER) << 1) | (heard_clearly << 2)]"
	var/list/list/cached_listeners_by_range = src.cached_listeners_by_range_message_origin[message.message_origin][flags]
	if (!cached_listeners_by_range)
		return

	if (!use_range_check)
		return cached_listeners_by_range

	. = cached_listeners_by_range["[message.heard_range]"]
	if (.)
		return

	for (var/cached_range in cached_listeners_by_range)
		if (text2num(cached_range) < message.heard_range)
			continue

		var/turf/centre = get_turf(message.message_origin)
		for (var/type in cached_listeners_by_range[cached_range])
			.[type] ||= list()
			for (var/datum/listen_module/input/input as anything in cached_listeners_by_range[cached_range][type])
				if (!INPUT_IN_RANGE(input, centre, message.heard_range))
					continue

				.[type] += input

		src.cached_listeners_by_range_message_origin[message.message_origin][flags]["[message.heard_range]"] = .
		return
