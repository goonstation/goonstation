/atom/movable/abstract_say_source/flock_system
	start_speech_outputs = list(SPEECH_OUTPUT_FLOCK_SYSTEM)
	default_speech_output_channel = SAY_CHANNEL_FLOCK
	say_language = LANGUAGE_FEATHER

/atom/movable/abstract_say_source/flock_system/New(loc, datum/flock/flock)
	. = ..()

	var/datum/speech_module/output/bundled/flock_say/system/output = src.ensure_say_tree().GetOutputByID(SPEECH_OUTPUT_FLOCK_SYSTEM)
	output.flock = flock
	output.subchannel = "\ref[flock]"
