/datum/speech_module/output/blobchat
	id = SPEECH_OUTPUT_BLOBCHAT
	channel = SAY_CHANNEL_BLOB

/datum/speech_module/output/blobchat/process(datum/say_message/message)
	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game blobsay'>\
			<span class='prefix'>BLOB: </span>\
			<span class='name text-normal' data-ctx='[mind_ref]'>\
	"}

	message.format_verb_prefix = {"\
		</span> \
		<span class='message'>\
	"}

	message.format_content_prefix = {"\
		, \
	"}

	message.format_content_suffix = {"\
		</span></span>\
	"}

	. = ..()
