/datum/listen_module/modifier/small_text
	id = LISTEN_MODIFIER_SMALL_TEXT

/datum/listen_module/modifier/small_text/process(datum/say_message/message)
	. = message
	message.loudness -= 1
