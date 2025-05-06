/datum/listen_module/effect/microphone_component
	id = LISTEN_EFFECT_MICROPHONE_COMPONENT

/datum/listen_module/effect/microphone_component/process(datum/say_message/message)
	var/obj/item/mechanics/miccomp/microphone = src.parent_tree.listener_parent
	if (!istype(microphone) || (microphone.level == OVERFLOOR) || !message.can_relay)
		return

	var/content
	if (microphone.add_sender)
		content = "name=[message.speaker_to_display]&message=[message.content]"
	else
		content = message.content

	SPAWN(0)
		microphone.light_up_housing()

	SEND_SIGNAL(microphone, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, content)
	global.animate_flash_color_fill(microphone, "#00FF00", 2, 2)
