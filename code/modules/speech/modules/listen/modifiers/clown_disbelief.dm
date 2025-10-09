/datum/listen_module/modifier/clown_disbelief
	id = LISTEN_MODIFIER_CLOWN_DISBELIEF
	priority = LISTEN_MODIFIER_PRIORITY_PROCESS_FIRST

/datum/listen_module/modifier/clown_disbelief/process(datum/say_message/message)
	. = message

	if(global.clown_disbelief_clown_mobs[message.original_speaker])
		return NO_MESSAGE
