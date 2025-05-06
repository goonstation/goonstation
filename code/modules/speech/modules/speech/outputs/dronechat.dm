/datum/speech_module/output/ghostdrone
	id = SPEECH_OUTPUT_GHOSTDRONE
	channel = SAY_CHANNEL_GHOSTDRONE

/datum/speech_module/output/ghostdrone/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT

	if (message.prefix == ";")
		return src.parent_tree.GetOutputByID(SPEECH_OUTPUT_DEADCHAT)?.process(message)

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game ghostdronesay broadcast'>\
			<span class='prefix'>DRONE: </span>\
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
