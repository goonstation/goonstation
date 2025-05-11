/datum/listen_module/effect/microphone
	id = LISTEN_EFFECT_MICROPHONE

/datum/listen_module/effect/microphone/process(datum/say_message/message)
	var/obj/item/device/microphone/microphone = src.parent_tree.listener_parent
	if (!istype(microphone) || !microphone.on || !CAN_RELAY_MESSAGE(message, SAY_RELAY_MICROPHONE))
		return

	var/feedback = FALSE
	var/list/obj/loudspeaker/loudspeakers = list()
	for_by_tcl(loudspeaker, /obj/loudspeaker)
		if (!IN_RANGE(microphone, loudspeaker, 7))
			continue

		if (IN_RANGE(microphone, loudspeaker, 2))
			feedback = TRUE

		loudspeakers += loudspeaker

	feedback &&= prob(10)

	message.message_size_override = clamp(length(loudspeakers) + microphone.font_amp, 0, microphone.max_font)
	message.output_module_channel = SAY_CHANNEL_OUTLOUD
	FORMAT_MESSAGE_FOR_RELAY(message, SAY_RELAY_MICROPHONE)

	for (var/obj/loudspeaker/loudspeaker as anything in loudspeakers)
		var/datum/say_message/loudspeaker_message = message.Copy()
		loudspeaker_message.speaker = loudspeaker
		loudspeaker_message.message_origin = loudspeaker
		loudspeaker.ensure_speech_tree().process(loudspeaker_message)

		if (feedback)
			loudspeaker.visible_message(SPAN_ALERT("[loudspeaker] lets out a horrible [pick("shriek", "squeal", "noise", "squawk", "screech", "whine", "squeak")]!"))
			playsound(loudspeaker.loc, 'sound/items/mic_feedback.ogg', 30, 1)
