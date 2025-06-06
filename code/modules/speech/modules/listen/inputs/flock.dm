/datum/listen_module/input/bundled/flock
	id = LISTEN_INPUT_FLOCK
	channel = SAY_CHANNEL_FLOCK


/datum/listen_module/input/bundled/flockmind
	id = LISTEN_INPUT_FLOCKMIND
	channel = SAY_CHANNEL_FLOCK

/datum/listen_module/input/bundled/flockmind/process(datum/say_message/message)
	if ((message.speaker != src.parent_tree.listener_parent) && istype(src.parent_tree.listener_parent, /mob/living/intangible/flock/flockmind))
		var/atom/origin
		if (ismob(message.speaker))
			origin = message.speaker
		else
			origin = message.speaker.loc

		if (origin)
			message.format_speaker_prefix += "<a href='byond://?src=\ref[src.parent_tree.listener_parent];origin=\ref[origin]'>"
			message.format_verb_prefix = "</a>" + message.format_verb_prefix

	. = ..()


/datum/listen_module/input/distorted_flock
	id = LISTEN_INPUT_FLOCK_DISTORTED
	priority = LISTEN_INPUT_PRIORITY_DISTORTED
	channel = SAY_CHANNEL_FLOCK_DISTORTED


/datum/listen_module/input/global_flock
	id = LISTEN_INPUT_FLOCK_GLOBAL
	priority = LISTEN_INPUT_PRIORITY_GLOBAL
	channel = SAY_CHANNEL_GLOBAL_FLOCK
