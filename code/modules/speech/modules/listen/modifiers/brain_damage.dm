/datum/listen_module/modifier/brain_damage
	id = LISTEN_MODIFIER_BRAIN_DAMAGE

/datum/listen_module/modifier/brain_damage/process(datum/say_message/message)
	message.content = stars(message.content, 50)
	. = ..()
