/datum/say_channel/delimited/local/outloud
	channel_id = SAY_CHANNEL_OUTLOUD
	listener_tick_cache_type = /datum/listener_tick_cache/outloud
#ifndef RP_MODE
	allows_urls = TRUE
#endif

/datum/say_channel/delimited/local/outloud/PassToChannel(datum/say_message/message)
	if (!(message.flags & SAYFLAG_WHISPER))
		var/list/list/datum/listen_module/input/listen_modules_by_type = src.listener_tick_cache.read_from_cache(message)
		if (islist(listen_modules_by_type))
			src.PassToListeners(message, listen_modules_by_type)
			return

		listen_modules_by_type = list()

		if (isturf(GET_MESSAGE_OUTERMOST_LISTENER_LOC(message)))
			var/turf/centre = get_turf(message.message_origin)
			if (!centre)
				return
			SET_UP_HEARD_TURFS(visible_turfs, message.heard_range, centre)

			for (var/type in src.listeners)
				listen_modules_by_type[type] ||= list()
				for (var/datum/listen_module/input/outloud/input as anything in src.listeners[type])
					// If the outermost listener's loc is a turf, perform line of sight and range checks.
					if (isturf(GET_INPUT_OUTERMOST_LISTENER_LOC(input)))
						// If the outermost listener's loc is a turf, they must be within the speaker's line of sight to hear the message.
						if (!input.ignore_line_of_sight_checks)
							if (!visible_turfs[GET_INPUT_OUTERMOST_LISTENER_LOC(input)])
								continue
							// If the input's hearing range is less than the message's heard range, ensure that the speaker and listener are within that range.
							if (input.hearing_range < message.heard_range)
								if (!INPUT_IN_RANGE(input, centre, input.hearing_range))
									continue
						// If the input ignores line of sight checks, then the listener may hear the message if they are within the lower of the hearing ranges.
						else
							var/min_heard_range = min(input.hearing_range, message.heard_range)
							if (!INPUT_IN_RANGE(input, centre, min_heard_range))
								continue
					// If the outermost listener's loc is not a turf, determine whether the message can be heard based on a shared loc chain.
					else if (CANNOT_HEAR_MESSAGE_FROM_LOC_CHAIN(input, message))
						continue

					listen_modules_by_type[type] += input

		else
			for (var/type in src.listeners)
				listen_modules_by_type[type] ||= list()
				for (var/datum/listen_module/input/outloud/input as anything in src.listeners[type])
					// Determine whether the message can be heard based on a shared loc chain.
					if (CANNOT_HEAR_MESSAGE_FROM_LOC_CHAIN(input, message))
						continue

					listen_modules_by_type[type] += input

		src.listener_tick_cache.write_to_cache(message, listen_modules_by_type)
		src.PassToListeners(message, listen_modules_by_type)

	// Whisper handling.
	else
		var/list/list/datum/listen_module/input/heard_clearly_listen_modules_by_type = src.listener_tick_cache.read_from_cache(message, TRUE)
		if (islist(heard_clearly_listen_modules_by_type))
			src.PassToListeners(message, heard_clearly_listen_modules_by_type)
			return

		heard_clearly_listen_modules_by_type = list()

		var/list/list/datum/listen_module/input/heard_distorted_listen_modules_by_type = src.listener_tick_cache.read_from_cache(message, FALSE)
		if (islist(heard_distorted_listen_modules_by_type))
			if (length(heard_distorted_listen_modules_by_type))
				var/datum/say_message/distorted_message = message.Copy()
				distorted_message.flags |= SAYFLAG_DELIMITED_CHANNEL_ONLY
				APPLY_CALLBACK_TO_MESSAGE_CONTENT(distorted_message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(stars)))

				src.PassToListeners(distorted_message, heard_distorted_listen_modules_by_type)

			return

		heard_distorted_listen_modules_by_type = list()

		if (isturf(GET_MESSAGE_OUTERMOST_LISTENER_LOC(message)))
			var/turf/centre = get_turf(message.message_origin)
			if (!centre)
				return
			SET_UP_HEARD_TURFS(heard_clearly_turfs, WHISPER_RANGE, centre)
			SET_UP_HEARD_DISTORTED_TURFS(heard_distorted_turfs, message.heard_range, centre, heard_clearly_turfs)

			for (var/type in src.listeners)
				heard_clearly_listen_modules_by_type[type] ||= list()
				heard_distorted_listen_modules_by_type[type] ||= list()
				for (var/datum/listen_module/input/outloud/input as anything in src.listeners[type])
					// If the input's hearing range is less than the message's heard range, ensure that the speaker and listener are within that range.
					if (input.hearing_range < message.heard_range)
						if (!INPUT_IN_RANGE(input, centre, input.hearing_range))
							continue
					// If the outermost listener's loc is a turf, they must be within the speaker's line of sight to hear the message.
					if (isturf(GET_INPUT_OUTERMOST_LISTENER_LOC(input)))
						// Use heard turfs to determine range.
						if (!input.ignore_line_of_sight_checks)
							// If within `WHISPER_RANGE`, the message may be heard clearly.
							if (heard_clearly_turfs[GET_INPUT_OUTERMOST_LISTENER_LOC(input)])
								heard_clearly_listen_modules_by_type[type] += input
								continue
							// If outside of `WHISPER_RANGE`, but still within message range, the message will be heard distorted.
							else if (heard_distorted_turfs[GET_INPUT_OUTERMOST_LISTENER_LOC(input)])
								heard_distorted_listen_modules_by_type[type] += input
								continue
						// Compute range directly without regard for heard turfs.
						else
							// If within `WHISPER_RANGE`, the message may be heard clearly.
							if (INPUT_IN_RANGE(input, centre, WHISPER_RANGE))
								heard_clearly_listen_modules_by_type[type] += input
								continue
							// If outside of `WHISPER_RANGE`, but still within message range, the message will be heard distorted.
							else if (INPUT_IN_RANGE(input, centre, message.heard_range))
								heard_distorted_listen_modules_by_type[type] += input
								continue
					// If the outermost listener's loc is not a turf, determine whether the message can be heard based on a shared loc chain.
					else
						if (CANNOT_HEAR_WHISPER_FROM_LOC_CHAIN(input, message))
							continue

						heard_clearly_listen_modules_by_type[type] += input

		else
			for (var/type in src.listeners)
				heard_clearly_listen_modules_by_type[type] ||= list()
				for (var/datum/listen_module/input/outloud/input as anything in src.listeners[type])
					// Determine whether the message can be heard based on a shared loc chain.
					if (CANNOT_HEAR_WHISPER_FROM_LOC_CHAIN(input, message))
						continue

					heard_clearly_listen_modules_by_type[type] += input

		src.listener_tick_cache.write_to_cache(message, heard_clearly_listen_modules_by_type, TRUE)
		src.PassToListeners(message, heard_clearly_listen_modules_by_type)
		if (length(heard_distorted_listen_modules_by_type))
			var/datum/say_message/distorted_message = message.Copy()
			distorted_message.flags |= SAYFLAG_DELIMITED_CHANNEL_ONLY
			APPLY_CALLBACK_TO_MESSAGE_CONTENT(distorted_message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(stars)))

			src.listener_tick_cache.write_to_cache(message, heard_distorted_listen_modules_by_type, FALSE)
			src.PassToListeners(distorted_message, heard_distorted_listen_modules_by_type)

/datum/say_channel/delimited/local/outloud/log_message(datum/say_message/message)
	var/content = ""
	if (message.flags & SAYFLAG_SINGING)
		content = "SAY: [html_encode(message.original_content)] [log_loc(message.speaker)]"
		phrase_log.log_phrase("sing", message.content, user = message.speaker, strip_html = TRUE)

	else if (message.flags & SAYFLAG_WHISPER)
		content = "SAY: [html_encode(message.original_content)] (WHISPER) [log_loc(message.speaker)]"
		phrase_log.log_phrase("whisper", message.content, user = message.speaker, strip_html = TRUE)

	else
		content = "SAY: [html_encode(message.original_content)] [log_loc(message.speaker)]"
		phrase_log.log_phrase("say", message.content, user = message.speaker, strip_html = TRUE)

	logTheThing(LOG_SAY, message.speaker, content)


/datum/say_channel/global_channel/outloud
	channel_id = SAY_CHANNEL_GLOBAL_OUTLOUD
	delimited_channel_id = SAY_CHANNEL_OUTLOUD
