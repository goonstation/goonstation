/datum/say_channel/delimited/local/looc
	channel_id = SAY_CHANNEL_LOOC
	enabled = FALSE
	disabled_message = "LOOC is currently disabled. For gameplay questions, try <a href='byond://winset?command=mentorhelp'>mentorhelp</a>."
	affected_by_modifiers = FALSE
	suppress_say_sound = TRUE
	suppress_hear_sound = TRUE
	suppress_speech_bubble = TRUE
	track_outermost_listener = FALSE
	listener_tick_cache_type = /datum/listener_tick_cache/origin_dependent

/datum/say_channel/delimited/local/looc/PassToChannel(datum/say_message/message)
	var/list/list/datum/listen_module/input/listen_modules_by_type = src.listener_tick_cache.read_from_cache(message)
	if (islist(listen_modules_by_type))
		src.PassToListeners(message, listen_modules_by_type)
		return

	listen_modules_by_type = list()

	var/turf/centre = get_turf(message.message_origin)
	if (!centre)
		return

	for (var/type in src.listeners)
		listen_modules_by_type[type] ||= list()
		for (var/datum/listen_module/input/input as anything in src.listeners[type])
			// If the listener is in range of the speaker, regardless of how nested they are, the listener may hear the message.
			if (!INPUT_IN_RANGE(input, centre, LOOC_RANGE))
				continue

			listen_modules_by_type[type] += input

	src.listener_tick_cache.write_to_cache(message, listen_modules_by_type)
	src.PassToListeners(message, listen_modules_by_type)

/datum/say_channel/ooc/log_message(datum/say_message/message)
	var/mob/M = message.speaker
	if (!istype(M) || !M.client || !(message.flags & SAYFLAG_SPOKEN_BY_PLAYER))
		return

	logTheThing(LOG_OOC, message.speaker, "([src.channel_id]): [message.content]")
	phrase_log.log_phrase("looc", message.content)


/datum/say_channel/global_channel/looc
	channel_id = SAY_CHANNEL_GLOBAL_LOOC
	delimited_channel_id = SAY_CHANNEL_LOOC
	affected_by_modifiers = FALSE
	suppress_say_sound = TRUE
	suppress_hear_sound = TRUE
	suppress_speech_bubble = TRUE
