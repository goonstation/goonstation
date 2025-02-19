/// Accesses an input module datum's outermost listener.
#define GET_INPUT_OUTERMOST_LISTENER(INPUT) INPUT.parent_tree.listener_origin.outermost_listener_tracker.outermost_listener
/// Accesses an input module datum's outermost listener's loc.
#define GET_INPUT_OUTERMOST_LISTENER_LOC(INPUT) INPUT.parent_tree.listener_origin.outermost_listener_tracker.outermost_listener.loc
/// Accesses a say message datum's outermost listener.
#define GET_MESSAGE_OUTERMOST_LISTENER(MESSAGE) MESSAGE.message_origin.outermost_listener_tracker.outermost_listener

/// Whether a message is able to be passed to a say channel.
#define CAN_PASS_MESSAGE_TO_SAY_CHANNEL(CHANNEL, MESSAGE) (CHANNEL.enabled || (ismob(message.speaker) && message.speaker:client?:holder))

/// Whether an input's parent's listener origin is within a range of a centre turf representing the position of the message origin. Takes into account turf vistargets.
#define INPUT_IN_RANGE(INPUT, CENTRE, RANGE) (IN_RANGE(INPUT.parent_tree.listener_origin, CENTRE, RANGE) || (CENTRE.vistarget && IN_RANGE(INPUT.parent_tree.listener_origin, CENTRE.vistarget, RANGE)))

/// Passes a say message datum to a say channel.
#define PASS_MESSAGE_TO_SAY_CHANNEL(CHANNEL, MESSAGE, ARGS...) \
	if (CAN_PASS_MESSAGE_TO_SAY_CHANNEL(CHANNEL, MESSAGE)) { \
		if (!length(MESSAGE.atom_listeners_override)) { \
			CHANNEL.PassToChannel(MESSAGE, ARGS); \
		} \
		else { \
			CHANNEL.PassToOverriddenAtomListeners(MESSAGE); \
		} \
	}

/// Relays a say message datum from one say channel to another.
#define RELAY_MESSAGE_TO_SAY_CHANNEL(CHANNEL, MESSAGE, ARGS...) \
	if (CAN_PASS_MESSAGE_TO_SAY_CHANNEL(CHANNEL, MESSAGE)) { \
		CHANNEL.PassToChannel(MESSAGE, ARGS); \
	}

/// Set up an associative list of heard turfs within a range in the form `list[turf] = TRUE`.
#define SET_UP_HEARD_TURFS(LIST, RANGE, CENTRE) \
	var/list/atom/LIST = list(); \
	for (var/turf/T in view(RANGE, CENTRE)) { \
		LIST[T] = TRUE; \
	} \
	if (CENTRE.vistarget) { \
		for (var/turf/T in view(RANGE, CENTRE.vistarget)) { \
			LIST[T] = TRUE ; \
		} \
	}

/// Set up an associative list of heard turfs within a range in the form `list[turf] = TRUE`, filtering out turfs already present in a second list.
#define SET_UP_HEARD_DISTORTED_TURFS(LIST, RANGE, CENTRE, HEARD_LIST) \
	var/list/atom/LIST = list(); \
	for (var/turf/T in view(RANGE, CENTRE)) { \
		if (HEARD_LIST[T]) { \
			continue; \
		} \
		LIST[T] = TRUE; \
	} \
	if (CENTRE.vistarget) { \
		for (var/turf/T in view(RANGE, CENTRE.vistarget)) { \
			if (HEARD_LIST[T]) { \
				continue; \
			} \
			LIST[T] = TRUE; \
		} \
	}


//------------ Say Channels ------------//
#define SAY_CHANNEL_BLOB "blob"
#define SAY_CHANNEL_DEAD "deadchat"
#define SAY_CHANNEL_GHOSTLY_WHISPER "ghostly_whisper"
#define SAY_CHANNEL_EQUIPPED "equipped"
#define SAY_CHANNEL_FLOCK "flock"
#define SAY_CHANNEL_GLOBAL_FLOCK "global_flock"
#define SAY_CHANNEL_DISTORTED_FLOCK "distorted_flock"
#define SAY_CHANNEL_GHOSTDRONE "ghostdrone"
#define SAY_CHANNEL_HIVEMIND "hivemind"
#define SAY_CHANNEL_GLOBAL_HIVEMIND "global_hivemind"
#define SAY_CHANNEL_OUTLOUD "outloud"
#define SAY_CHANNEL_GLOBAL_OUTLOUD "global_outloud"
#define SAY_CHANNEL_LOOC "looc"
#define SAY_CHANNEL_GLOBAL_LOOC "global_looc"
#define SAY_CHANNEL_MARTIAN "martian"
#define SAY_CHANNEL_MENTOR_MOUSE "mentor_mouse"
#define SAY_CHANNEL_OOC "ooc"
#define SAY_CHANNEL_GLOBAL_RADIO "global_radio"
#define SAY_CHANNEL_GLOBAL_RADIO_DEFAULT_ONLY "global_radio_default"
#define SAY_CHANNEL_GLOBAL_RADIO_UNPROTECTED_ONLY "global_radio_unprotected"
#define SAY_CHANNEL_SILICON "silicon"
#define SAY_CHANNEL_THRALL "thrall"
#define SAY_CHANNEL_GLOBAL_THRALL "global_thrall"
#define SAY_CHANNEL_KUDZU "kudzu"
