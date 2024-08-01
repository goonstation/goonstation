/datum/speech_module/output/bundled/thrallchat
	id = SPEECH_OUTPUT_THRALLCHAT
	channel = SAY_CHANNEL_THRALL
	var/role = ""
	var/css_class = ""

/datum/speech_module/output/bundled/thrallchat/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game thrallsay'>\
			<span class='prefix'>THRALLSPEAK: </span>\
			<span class='name [src.css_class]' data-ctx='[mind_ref]'>\
	"}

	message.format_verb_prefix = {"\
		<span class='text-normal'>[src.role]</span></span> \
		<span class='message'>\
	"}

	message.format_content_prefix = {"\
		, \
	"}

	message.format_content_suffix = {"\
		</span></span>\
	"}

	. = ..()


/datum/speech_module/output/bundled/thrallchat/vampire
	id = SPEECH_OUTPUT_THRALLCHAT_VAMPIRE
	role = " (VAMPIRE)"
	css_class = "vamp"


/datum/speech_module/output/bundled/thrallchat/thrall
	id = SPEECH_OUTPUT_THRALLCHAT_THRALL
	role = " (THRALL)"


/datum/speech_module/output/bundled/thrallchat/global_thrallchat
	id = SPEECH_OUTPUT_THRALLCHAT_GLOBAL
	channel = SAY_CHANNEL_GLOBAL_THRALL
