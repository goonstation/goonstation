/datum/speech_module/output/kudzuchat
	id = SPEECH_OUTPUT_KUDZUCHAT
	channel = SAY_CHANNEL_KUDZU
	speech_prefix = SPEECH_PREFIX_KUDZUCHAT

/datum/speech_module/output/kudzuchat/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game kudzusay'>\
			<span class='prefix'><small>KUDZU: </small></span>\
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


/datum/speech_module/output/kudzuchat/admin
	id = SPEECH_OUTPUT_KUDZUCHAT_ADMIN
	speech_prefix = null
