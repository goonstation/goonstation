/datum/listen_module/effect/bradbury
	id = LISTEN_EFFECT_BRADBURY

/datum/listen_module/effect/bradbury/process(datum/say_message/message)
	var/obj/machinery/derelict_aiboss/ai/bradbury = src.parent_tree.listener_parent
	if (!istype(bradbury) || !bradbury.on || !message.can_relay || prob(95))
		return

	SPAWN(0)
		bradbury.say(message.content, message_params = list("can_relay" = FALSE))
		playsound(bradbury, 'sound/machines/modem.ogg', 80, TRUE)
