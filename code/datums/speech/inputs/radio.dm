TYPEINFO(/datum/listen_module/input/radio)
	id = "radio"
/datum/listen_module/input/radio
	id = "radio"
	channel = SAY_CHANNEL_RADIO_PREFIX+"none"

	process(datum/say_message/message)
		. = ..()
