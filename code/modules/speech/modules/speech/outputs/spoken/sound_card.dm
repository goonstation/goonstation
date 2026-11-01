/datum/speech_module/output/spoken/sound_card
	id = SPEECH_OUTPUT_SPOKEN_SOUND_CARD

/datum/speech_module/output/spoken/sound_card/format(datum/say_message/message)
	var/obj/item/peripheral/sound_card/speaker = message.speaker

	message.format_speaker_prefix = {"\
		[bicon(speaker.host)]\
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
		</span>\
	"}
