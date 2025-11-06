/datum/listener_tick_cache/origin_dependent

/datum/listener_tick_cache/origin_dependent/write_to_cache(datum/say_message/message, list/list/datum/listen_module/input/listeners)
	if (src.cache_tick != world.time)
		src.cached_listeners_by_range_message_origin = null

	src.cache_tick = world.time

	src.cached_listeners_by_range_message_origin ||= list()
	src.cached_listeners_by_range_message_origin[message.message_origin] = listeners

/datum/listener_tick_cache/origin_dependent/read_from_cache(datum/say_message/message)
	RETURN_TYPE(/list/list/datum/listen_module/input)

	if (!src.cached_listeners_by_range_message_origin)
		return

	if (src.cache_tick != world.time)
		src.cached_listeners_by_range_message_origin = null
		return

	return src.cached_listeners_by_range_message_origin[message.message_origin]
