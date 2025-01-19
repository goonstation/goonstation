/datum/listen_module/effect/ritualhear
	id = LISTEN_EFFECT_RITUAL

/datum/listen_module/effect/ritualhear/process(datum/say_message/message)
	var/atom/A = src.parent_tree.listener_parent
	if (!istype(A))
		return

	A.ritualComponent?.hear(message)
