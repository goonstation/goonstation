/datum/listen_module/modifier/brain_damage
	id = LISTEN_MODIFIER_BRAIN_DAMAGE

/datum/listen_module/modifier/brain_damage/process(datum/say_message/message)
	APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(stars), 50))
	. = message
