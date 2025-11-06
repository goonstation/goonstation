/datum/shared_input_format_module/spooky
	id = LISTEN_INPUT_GHOSTLY_WHISPER

/datum/shared_input_format_module/spooky/process(datum/say_message/message)
	. = message

	message.flags |= SAYFLAG_NO_MAPTEXT | SAYFLAG_NO_SAY_VERB
	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS
	message.speaker_to_display = ""

	message.format_speaker_prefix = ""
	message.format_verb_prefix = ""

	message.format_content_prefix = {"\
		<span class='game deadsay'><i>\
	"}

	message.format_content_suffix = {"\
		</i></span>\
	"}
