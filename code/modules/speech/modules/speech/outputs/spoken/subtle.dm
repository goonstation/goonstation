/datum/speech_module/output/spoken/subtle
	id = SPEECH_OUTPUT_SPOKEN_SUBTLE
	send_to_global = FALSE

/datum/speech_module/output/spoken/subtle/format(datum/say_message/message)
	// Set default maptext colour and alpha:
	message.maptext_css_values["color"] ||= "#C2BEBE"
	if (message.maptext_variables["alpha"] == 255)
		message.maptext_variables["alpha"] = 140

	// Create a text reference to the speaker's mind, if they have one.
	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"


	message.format_speaker_prefix = {"\
		<span class='subtle'>\
		<span class='name' data-ctx='[mind_ref]'>\
		<b>\
	"}

	message.format_verb_prefix = {"\
		</b></span> \
		<span class='message'>\
	"}

	message.format_content_prefix = {"\
		, \
	"}

	message.format_content_suffix = {"\
		</span></span>\
	"}
