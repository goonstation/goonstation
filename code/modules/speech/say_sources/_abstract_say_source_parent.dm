/**
 *	Abstract say sources are a method to send say message datums over a channel without a tangible speaker atom. They exist in
 *	nullspace, and are typically used as sources for announcement messages.
 */
TYPEINFO(/atom/movable/abstract_say_source)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN)

/atom/movable/abstract_say_source
	name = "Unknown"

	speech_verb_say = "says"
	speech_verb_ask = null
	speech_verb_exclaim = null
	speech_verb_stammer = null
	speech_verb_gasp = null

	default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	say_language = LANGUAGE_ENGLISH


/**
 *	Abstract radio say sources are a method to send say message datums over a radio channel. This is achieved by routing the say
 *	message datum to a radio object, broadcasting the message as a packet.
 */
TYPEINFO(/atom/movable/abstract_say_source/radio)
	start_speech_outputs = list(SPEECH_OUTPUT_EQUIPPED)

/atom/movable/abstract_say_source/radio
	default_speech_output_channel = SAY_CHANNEL_EQUIPPED

	var/radio_type = /obj/item/device/radio
	var/obj/item/device/radio/radio
	var/default_frequency = R_FREQ_DEFAULT
	var/radio_chat_class = RADIOCL_STANDARD
	var/radio_icon = null
	var/radio_icon_tooltip = ""

/atom/movable/abstract_say_source/radio/New()
	. = ..()

	src.radio = new src.radio_type(src)
	src.radio.toggle_microphone(FALSE)
	src.radio.toggle_speaker(FALSE)
	src.radio.ensure_listen_tree().AddListenInput(LISTEN_INPUT_EQUIPPED)

	src.radio.set_frequency(src.default_frequency)
	src.radio.chat_class = src.radio_chat_class
	src.radio.icon_override = src.radio_icon
	src.radio.icon_tooltip = src.radio_icon_tooltip

/atom/movable/abstract_say_source/radio/disposing()
	qdel(src.radio)
	src.radio = null

	. = ..()

