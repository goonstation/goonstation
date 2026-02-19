/datum/speech_module/modifier/abstract_radio_source
	id = SPEECH_MODIFIER_ABSTRACT_RADIO_SOURCE
	priority = SPEECH_MODIFIER_PRIORITY_PROCESS_FIRST

/datum/speech_module/modifier/abstract_radio_source/process(datum/say_message/message)
	. = message

	var/atom/movable/abstract_say_source/radio/abstract_radio_source = message.speaker
	if (!istype(abstract_radio_source))
		return

	message.prefix = abstract_radio_source.radio_prefix
