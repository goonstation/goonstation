TYPEINFO(/atom/movable/abstract_say_source/flock_system)
	start_speech_outputs = null

/atom/movable/abstract_say_source/flock_system
	name = @"[SYSTEM]"
	default_speech_output_channel = SAY_CHANNEL_FLOCK
	say_language = LANGUAGE_FEATHER
	speech_verb_say = "alerts"

/atom/movable/abstract_say_source/flock_system/New(loc, datum/flock/flock)
	. = ..()

	src.internal_name = "Flock System \[[flock.name]\]"
	src.ensure_speech_tree().AddSpeechOutput(SPEECH_OUTPUT_FLOCK_SYSTEM, subchannel = "\ref[flock]", flock = flock)
