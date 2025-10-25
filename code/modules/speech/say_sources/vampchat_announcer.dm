var/atom/movable/abstract_say_source/vampchat/vampchat_announcer = new()

TYPEINFO(/atom/movable/abstract_say_source/vampchat)
	start_speech_outputs = list(SPEECH_OUTPUT_VAMPCHAT_ANNOUNCER)

/atom/movable/abstract_say_source/vampchat
	default_speech_output_channel = SAY_CHANNEL_VAMPIRE
	say_language = LANGUAGE_ENGLISH
