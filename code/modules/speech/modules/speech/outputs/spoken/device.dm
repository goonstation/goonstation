/datum/speech_module/output/spoken/device
	id = SPEECH_OUTPUT_SPOKEN_DEVICE

/datum/speech_module/output/spoken/device/format(datum/say_message/message)
	message.maptext_css_values["color"] ||= "#FFBF00"

	message.format_speaker_prefix = {"\
		<span class='game radio' style='color: #FFBF00;'>\
		[bicon(message.speaker)]\
		<span class='name'>\
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
