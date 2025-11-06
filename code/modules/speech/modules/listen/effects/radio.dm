/datum/listen_module/effect/radio
	id = LISTEN_EFFECT_RADIO

/datum/listen_module/effect/radio/process(datum/say_message/message)
	var/obj/item/device/radio/radio = src.parent_tree.listener_parent
	if (!istype(radio) || radio.bricked)
		return

	var/signal_frequency
	// `copytext` returns the message prefix without the leading colon.
	var/radio_prefix = copytext(message.prefix, 2, length(message.prefix) + 1)
	// Only default to general frequency if you didn't try talking on a different channel
	if (length(radio.secure_frequencies) && radio.secure_frequencies[radio_prefix])
		signal_frequency = radio.secure_frequencies[radio_prefix]
	else if (!radio_prefix)
		signal_frequency = radio.frequency
	else //Just whisper, don't try talking crime on general
		return

	if (signal_frequency != R_FREQ_DEFAULT)
		message.hear_sound = 'sound/misc/talk/radio2.ogg'

	else if (global.signal_loss && !radio.hardened) // Prevent broadcasting to the general frequency during a solar flare.
		return

	if (isAI(message.speaker))
		message.hear_sound = 'sound/misc/talk/radio_ai.ogg'

	radio.last_transmission = world.time
	src.send_signal(message, radio, signal_frequency)

/// Create and post the radio packet containing the message datum and handle any other associated effects.
/datum/listen_module/effect/radio/proc/send_signal(datum/say_message/message, obj/item/device/radio/radio, signal_frequency)
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = radio
	signal.encryption = "\ref[radio]"
	signal.data["message"] = message

	if (!SEND_SIGNAL(radio, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, signal_frequency))
		return

	radio.ensure_speech_tree()

	// Send the message to the global radio channel.
	var/datum/say_message/global_message = message.Copy()
	global_message.output_module_channel = SAY_CHANNEL_GLOBAL_RADIO
	radio.speech_tree.process(global_message)

	// If the message has been sent on the default frequency, send it to the global radio default channel.
	if (signal_frequency == R_FREQ_DEFAULT)
		var/datum/say_message/radio_default_message = message.Copy()
		radio_default_message.output_module_channel = SAY_CHANNEL_GLOBAL_RADIO_DEFAULT_ONLY
		radio.speech_tree.process(radio_default_message)

	// If the radio and frequency is unprotected, send it to the global radio unprotected channel.
	if (!radio.protected_radio && isnull(radio.traitorradio) && !(signal_frequency in global.protected_frequencies))
		var/datum/say_message/radio_unprotected_message = message.Copy()
		radio_unprotected_message.output_module_channel = SAY_CHANNEL_GLOBAL_RADIO_UNPROTECTED_ONLY
		radio.speech_tree.process(radio_unprotected_message)


/datum/listen_module/effect/radio/tutorial
	id = LISTEN_EFFECT_RADIO_TUTORIAL

/datum/listen_module/effect/radio/tutorial/send_signal(datum/say_message/message, obj/item/device/radio/radio, signal_frequency)
	if (!radio.speaker_enabled || !(radio.wires & 2))
		return

	// Circumvent the packet network completely and directly route this message to the radio.
	message.speaker = radio
	message.message_origin = radio
	message.heard_range = radio.speaker_range

	radio.ensure_speech_tree().process(message)
