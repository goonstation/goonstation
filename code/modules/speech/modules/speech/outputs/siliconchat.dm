/datum/speech_module/output/siliconchat
	id = SPEECH_OUTPUT_SILICONCHAT
	channel = SAY_CHANNEL_SILICON
	var/add_prefix = TRUE

/datum/speech_module/output/siliconchat/New(datum/speech_module_tree/parent)
	. = ..()

	if (src.add_prefix)
		src.parent_tree.AddSpeechPrefix(SPEECH_PREFIX_SILICON)

/datum/speech_module/output/siliconchat/disposing()
	if (src.add_prefix)
		src.parent_tree.RemoveSpeechPrefix(SPEECH_PREFIX_SILICON)

	. = ..()

/datum/speech_module/output/siliconchat/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT
	message.language = global.SpeechManager.GetLanguageInstance(LANGUAGE_SILICON)

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game roboticsay'>\
			<span class='prefix'>Robotic Talk: </span>\
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


/datum/speech_module/output/siliconchat/admin
	id = SPEECH_OUTPUT_SILICONCHAT_ADMIN
	add_prefix = FALSE
