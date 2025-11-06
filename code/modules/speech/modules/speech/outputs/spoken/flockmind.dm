/datum/speech_module/output/spoken/flockmind
	id = SPEECH_OUTPUT_SPOKEN_FLOCKMIND

/datum/speech_module/output/spoken/flockmind/format(datum/say_message/message)
	message.speaker_to_display = "Unknown"
	message.say_verb = "crackles"

	var/mind_ref = ""
	var/flock_name = "--.--"
	if (isflockmob(message.original_speaker))
		var/mob/living/intangible/flock/flockmind = message.original_speaker
		mind_ref = "\ref[flockmind.mind]"
		flock_name = flockmind.flock?.name

	var/classes = ""
	var/colour = ""
	var/radio_icon = ""
	if (istype(message.speaker, /obj/item/device/radio))
		var/obj/item/device/radio/radio = message.speaker
		classes = radio.chat_class
		colour = radio.device_color
		radio_icon = bicon(radio)

	message.format_speaker_prefix = {"\
		<span class='radio [classes]' style='color: [colour]'>\
			[radio_icon]<span class='name' data-ctx='[mind_ref]'>\
	"}

	message.format_verb_prefix = {"\
		</span> \
		<b>\[[flock_name]\]</b> \
		<span class='message'>\
	"}

	message.format_content_prefix = {"\
		, \
	"}

	message.format_content_suffix = {"\
		</span></span>\
	"}
