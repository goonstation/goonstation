/datum/speech_module/output/vampchat
	id = SPEECH_OUTPUT_VAMPCHAT
	channel = SAY_CHANNEL_VAMPIRE
	speech_prefix = SPEECH_PREFIX_VAMPCHAT

/datum/speech_module/output/vampchat/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT
	message.hear_sound = pick(
		'sound/voice/creepywhisper_1.ogg',
		'sound/voice/creepywhisper_2.ogg',
		'sound/voice/creepywhisper_3.ogg',
	)

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game thrallsay'>\
			<span class='prefix'>VAMP: </span>\
			<span class='name' data-ctx='[mind_ref]'>\
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
