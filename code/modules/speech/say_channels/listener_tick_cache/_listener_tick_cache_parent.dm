/**
 *	Listener tick caches are responsible for storing the "listeners by type" lists calculated by `PassToChannel()` for a single tick.
 *	This allows all other hearing operations occuring on the same tick from the same origin to quickly retrieve the relevant listeners;
 *	this is why speaking into over ten radios at once doesn't grind the game to a halt.
 */
/datum/listener_tick_cache
	/// A list of message origins, and the cached `listen_module_by_type` lists associated with that origin at a specific range.
	var/list/list/datum/listen_module/input/cached_listeners_by_range_message_origin
	/// The tick for which `cached_listeners_by_message_origin` is valid.
	var/cache_tick

/// Temporarily cache a list of listeners by type. The depth of this list is dependent on the number of conditions that the associated say channel considers.
/datum/listener_tick_cache/proc/write_to_cache(datum/say_message/message, list/list/datum/listen_module/input/listeners)
	if (src.cache_tick != world.time)
		src.cached_listeners_by_range_message_origin = null

	src.cache_tick = world.time

	var/use_range_check = isturf(GET_MESSAGE_OUTERMOST_LISTENER_LOC(message))
	src.cached_listeners_by_range_message_origin ||= list()
	src.cached_listeners_by_range_message_origin[message.message_origin] ||= list()

	if (use_range_check)
		src.cached_listeners_by_range_message_origin[message.message_origin]["[use_range_check]"] ||= list()
		src.cached_listeners_by_range_message_origin[message.message_origin]["[use_range_check]"]["[message.heard_range]"] = listeners
	else
		src.cached_listeners_by_range_message_origin[message.message_origin]["[use_range_check]"] = listeners

/// Attempt to retrieve a list of listeners by type, if it exists.
/datum/listener_tick_cache/proc/read_from_cache(datum/say_message/message)
	RETURN_TYPE(/list/list/datum/listen_module/input)

	if (!src.cached_listeners_by_range_message_origin || !src.cached_listeners_by_range_message_origin[message.message_origin])
		return

	if (src.cache_tick != world.time)
		src.cached_listeners_by_range_message_origin = null
		return

	var/use_range_check = isturf(GET_MESSAGE_OUTERMOST_LISTENER_LOC(message))
	var/list/list/cached_listeners_by_range = src.cached_listeners_by_range_message_origin[message.message_origin]["[use_range_check]"]
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

		src.cached_listeners_by_range_message_origin[message.message_origin]["[use_range_check]"]["[message.heard_range]"] = .
		return
