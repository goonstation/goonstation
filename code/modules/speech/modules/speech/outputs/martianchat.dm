/datum/speech_module/output/martian
	id = SPEECH_OUTPUT_MARTIAN
	channel = SAY_CHANNEL_MARTIAN
	var/class = "martiansay"

/datum/speech_module/output/martian/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT
	message.say_verb = "telepathically messages"

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game [class]'>\
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


/datum/speech_module/output/martian/leader
	id = SPEECH_OUTPUT_MARTIAN_LEADER
	class = "martianimperial"
