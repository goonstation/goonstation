var/atom/movable/abstract_say_source/random_accent/random_accent_source = new()

/atom/movable/abstract_say_source/random_accent
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN)
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	say_language = LANGUAGE_ENGLISH

/atom/movable/abstract_say_source/random_accent/proc/process_message(message)
	RETURN_TYPE(/datum/say_message)

	qdel(src.say_tree)
	src.say_tree = null
	src.ensure_say_tree()

	while (prob(5))
		src.say_tree.AddSpeechModifier(global.random_accent().id)

	return src.say(message, flags = SAYFLAG_DO_NOT_OUTPUT)
