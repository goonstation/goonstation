/// Accesses an input module datum's outermost listener.
#define GET_INPUT_OUTERMOST_LISTENER(INPUT) INPUT.parent_tree.parent.outermost_listener_tracker.outermost_listener
/// Accesses an input module datum's outermost listener's loc.
#define GET_INPUT_OUTERMOST_LISTENER_LOC(INPUT) INPUT.parent_tree.parent.outermost_listener_tracker.outermost_listener.loc
/// Accesses a say message datum's outermost listener.
#define GET_MESSAGE_OUTERMOST_LISTENER(MESSAGE) MESSAGE.speaker.outermost_listener_tracker.outermost_listener

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
#define SAY_CHANNEL_SILICON "silicon"
#define SAY_CHANNEL_THRALL "thrall"
#define SAY_CHANNEL_GLOBAL_THRALL "global_thrall"
#define SAY_CHANNEL_KUDZU "kudzu"

//------------ Static Channel Prefixes ------------//
/// A list of channel prefixes that will always correspond to a specific say channel regardless of context.
var/list/static_channel_prefixes = list(
	":ooc" = SAY_CHANNEL_OOC,
	":looc" = SAY_CHANNEL_LOOC,
	":s" = SAY_CHANNEL_SILICON,
)

