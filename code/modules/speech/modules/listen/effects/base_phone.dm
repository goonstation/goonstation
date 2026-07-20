/datum/listen_module/effect/base_phone
	id = LISTEN_EFFECT_BASE_PHONE

/datum/listen_module/effect/base_phone/process(datum/say_message/message)
	SEND_SIGNAL(src.parent_tree.listener_parent, COMSIG_PHONE_SPEECH_TREE_INPUT, message)
