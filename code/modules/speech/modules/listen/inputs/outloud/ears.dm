/datum/listen_module/input/outloud/ears
	id = LISTEN_INPUT_EARS

/datum/listen_module/input/outloud/ears/process(datum/say_message/message)
	// The speaker and/or listener is inside of something.
	if ((!isturf(src.parent_tree.listener_origin.loc) || !isturf(message.message_origin.loc)) && (src.parent_tree.listener_origin != message.message_origin.loc) && !(message.flags & SAYFLAG_IGNORE_POSITION))
		// Get the relative muffling between the speaker and listener.
		var/relative_thickness = 0
		var/atom/movable/speaker_loc = message.speaker.loc
		var/atom/movable/outermost
		var/matched_loc = FALSE

		while (!isturf(speaker_loc))
			if (isnull(speaker_loc))
				return

			outermost = speaker_loc
			if (speaker_loc == src.parent_tree.listener_origin.loc)
				matched_loc = TRUE
				break

			else
				relative_thickness += speaker_loc.soundproofing
				speaker_loc = speaker_loc.loc

		if (!matched_loc)
			var/atom/movable/hearer_loc = src.parent_tree.listener_origin.loc
			while (!isturf(hearer_loc))
				relative_thickness += hearer_loc.soundproofing
				hearer_loc = hearer_loc.loc

		// Format the message based on thickness.
		if (isnull(outermost) || (relative_thickness < 0) || (matched_loc && (relative_thickness == 0)))
			message.speaker_location_text = ""

		else if (relative_thickness == 0)
			message.speaker_location_text = "(on [bicon(outermost)] [outermost])"

		else if (relative_thickness < 10)
			message.speaker_location_text = "(inside [bicon(outermost)] [outermost])"

		else if (relative_thickness < 20)
			message.speaker_to_display = "muffled"
			message.speaker_location_text = "(inside [bicon(outermost)] [outermost])"

		else
			return

	. = ..()


/datum/listen_module/input/outloud/ears/ghostdrone
	id = LISTEN_INPUT_EARS_GHOSTDRONE

/datum/listen_module/input/outloud/ears/ghostdrone/process(datum/say_message/message)
	message.speaker_to_display = message.voice_ident

	. = ..()


/datum/listen_module/input/outloud/ears/ai
	id = LISTEN_INPUT_EARS_AI


SET_UP_LISTEN_CONTROL(/datum/listen_module/input/outloud/ears/ghost, LISTEN_CONTROL_TOGGLE_GLOBAL_HEARING_GHOST)
/datum/listen_module/input/outloud/ears/ghost
	id = LISTEN_INPUT_EARS_GHOST
	ignore_line_of_sight_checks = TRUE
