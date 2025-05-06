var/atom/movable/abstract_say_source/random_accent/random_accent_source = new()

TYPEINFO(/atom/movable/abstract_say_source/random_accent)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN)

/atom/movable/abstract_say_source/random_accent
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	say_language = LANGUAGE_ENGLISH

/atom/movable/abstract_say_source/random_accent/proc/process_message(message)
	RETURN_TYPE(/datum/say_message)

	qdel(src.speech_tree)
	src.speech_tree = null
	src.ensure_speech_tree()

	while (prob(5))
		src.speech_tree.AddSpeechModifier(global.random_accent().id)

	return src.say(message, flags = SAYFLAG_DO_NOT_OUTPUT)
