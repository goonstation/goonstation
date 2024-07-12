var/atom/movable/abstract_say_source/random_accent/random_accent_source = new()

/atom/movable/abstract_say_source/random_accent
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN)
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	say_language = LANGUAGE_ENGLISH

/atom/movable/abstract_say_source/random_accent/proc/process_message(message)
	RETURN_TYPE(/datum/say_message)

	src.ensure_say_tree()

	for (var/modifier_id in src.say_tree.speech_modifiers_by_id)
		src.say_tree.RemoveModifier(modifier_id)

	while (prob(5))
		src.say_tree.AddModifier(global.random_accent().id)

	return src.say(message, flags = SAYFLAG_DO_NOT_OUTPUT)
