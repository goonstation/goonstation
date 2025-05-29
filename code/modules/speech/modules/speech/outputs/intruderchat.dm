/datum/speech_module/output/intruderchat
	id = SPEECH_OUTPUT_INTRUDERCHAT
	channel = SAY_CHANNEL_INTRUDER
	speech_prefix = SPEECH_PREFIX_INTRUDERCHAT

/datum/speech_module/output/intruderchat/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game intrudersay'>\
			<span class='prefix'><small>INTRUSION: </small></span>\
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

/datum/speech_module/output/intruderchat/admin
	id = SPEECH_OUTPUT_INTRUDERCHAT_ADMIN
	speech_prefix = null
