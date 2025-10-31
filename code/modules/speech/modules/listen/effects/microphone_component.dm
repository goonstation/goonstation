/datum/listen_module/effect/microphone_component
	id = LISTEN_EFFECT_MICROPHONE_COMPONENT

/datum/listen_module/effect/microphone_component/process(datum/say_message/message)
	var/obj/item/mechanics/miccomp/microphone = src.parent_tree.listener_parent
	if (!istype(microphone) || (microphone.level == OVERFLOOR) || !message.can_relay)
		return

	var/content
	if (microphone.add_sender)
		if (isnull(message.speaker_to_display))
			message.speaker_to_display = message.real_ident || message.face_ident

		content = "name=[message.speaker_to_display]&message=[message.content]"

	else
		content = message.content

	//we're sending it to in-game components now, so strip our internal mutability handling tags
	content = STRIP_MUTABLE_CONTENT_TAGS(content)
	content = strip_html_tags(content)

	SPAWN(0)
		microphone.light_up_housing()

	SEND_SIGNAL(microphone, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, content)
	global.animate_flash_color_fill(microphone, "#00FF00", 2, 2)
