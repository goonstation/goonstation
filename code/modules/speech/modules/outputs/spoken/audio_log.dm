/datum/speech_module/output/spoken/audio_log
	id = SPEECH_OUTPUT_SPOKEN_AUDIO_LOG

/datum/speech_module/output/spoken/audio_log/format(datum/say_message/message)
	var/obj/item/device/audio_log/audio_log = message.speaker
	if (!istype(audio_log))
		return

	var/message_colour = message.maptext_css_values["color"]
	if (!message_colour)
		if (message.speaker_to_display && audio_log.name_colours[message.speaker_to_display])
			message_colour = audio_log.name_colours[message.speaker_to_display]
		else
			message_colour = audio_log.text_colour

		message.maptext_css_values["color"] = message_colour

	message.flags |= SAYFLAG_NO_SAY_VERB

	message.format_speaker_prefix = {"\
		<span class='game radio' style='color: [message_colour];'>\
		<span class='name'>\
		<b>\
	"}

	message.format_verb_prefix = {"\
		</span> \
		[bicon(message.speaker)]\[Log\]\
		</b> \
		<span class='message'>\
	"}

	message.format_content_prefix = ""

	message.format_content_suffix = {"\
		</span></span>\
	"}
