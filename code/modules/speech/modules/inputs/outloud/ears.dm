/datum/listen_module/input/outloud/ears
	id = LISTEN_INPUT_EARS

/datum/listen_module/input/outloud/ears/process(datum/say_message/message)
	// The speaker and/or listener is inside of something.
	if ((!isturf(src.parent_tree.parent.loc) || !isturf(message.speaker.loc)) && (src.parent_tree.parent != message.speaker.loc) && !(message.flags & SAYFLAG_IGNORE_POSITION))
		// Get the relative muffling between the speaker and listener.
		var/relative_thickness = 0
		var/atom/movable/speaker_loc = message.speaker.loc
		var/atom/movable/outermost
		var/matched_loc = FALSE

		while(!isturf(speaker_loc))
			if (isnull(speaker_loc))
				return

			outermost = speaker_loc
			if (speaker_loc == src.parent_tree.parent.loc)
				matched_loc = TRUE
				break

			else
				relative_thickness += speaker_loc.soundproofing
				speaker_loc = speaker_loc.loc

		if (!matched_loc)
			var/atom/movable/hearer_loc = src.parent_tree.parent.loc
			while(!isturf(hearer_loc))
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
			message.card_ident = null //muffled voicetype - hacky, use a flag instead
			message.speaker_location_text = "muffled (inside [bicon(outermost)] [outermost])"

		else
			return

	. = ..()


/datum/listen_module/input/outloud/ears/ai
	id = LISTEN_INPUT_EARS_AI
