/datum/listen_module/effect/radio
	id = LISTEN_EFFECT_RADIO

/datum/listen_module/effect/radio/process(datum/say_message/message)
	var/obj/item/device/radio/radio = src.parent_tree.listener_parent
	if (!istype(radio) || radio.bricked)
		return

	var/signal_frequency
	if (length(radio.secure_frequencies))
		// `copytext` returns the message prefix without the leading colon.
		signal_frequency = radio.secure_frequencies[copytext(message.prefix, 2, length(message.prefix) + 1)]

	signal_frequency ||= radio.frequency

	if (signal_frequency != R_FREQ_DEFAULT)
		message.hear_sound = 'sound/misc/talk/radio2.ogg'

	else if (global.signal_loss && !radio.hardened) // Prevent broadcasting to the general frequency during a solar flare.
		return

	if (isAI(message.speaker))
		message.hear_sound = 'sound/misc/talk/radio_ai.ogg'

	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = radio
	signal.encryption = "\ref[radio]"
	signal.data["message"] = message

	radio.last_transmission = world.time

	if (SEND_SIGNAL(radio, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, signal_frequency))
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
