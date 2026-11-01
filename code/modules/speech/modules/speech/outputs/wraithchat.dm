/datum/speech_module/output/wraithchat
	id = SPEECH_OUTPUT_WRAITHCHAT
	priority = SPEECH_OUTPUT_PRIORITY_DEFAULT
	channel = SAY_CHANNEL_WRAITH
	speech_prefix = SPEECH_PREFIX_WRAITHCHAT
	var/role = null

/datum/speech_module/output/wraithchat/process(datum/say_message/message)
	var/maptext_colour = dead_maptext_color(message.speaker.name)

	message.maptext_css_values["color"] = maptext_colour
	message.maptext_animation_colours = list(
		maptext_colour,
		"#ac3232",
	)

	message.flags |= SAYFLAG_DO_NOT_PASS_TO_IMPORTING_TREES
	message.say_verb = "howls"

	if (src.role)
		message.speaker_to_display = "([message.real_ident])"

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game wraithsay'>\
			<span class='prefix'>WRAITH: </span>\
			<span class='name' data-ctx='[mind_ref]'>[src.role]<span class='text-normal'> \
	"}

	message.format_verb_prefix = {"\
		</span></span> \
		<span class='message'>\
	"}

	message.format_content_prefix = {"\
		, \
	"}

	message.format_content_suffix = {"\
		</span></span>\
	"}

	. = ..()


/datum/speech_module/output/wraithchat/wraith
	id = SPEECH_OUTPUT_WRAITHCHAT_WRAITH
	priority = SPEECH_OUTPUT_PRIORITY_HIGH
	role = "Wraith"

/datum/speech_module/output/wraithchat/wraith/process(datum/say_message/message)
	message.hear_sound = pick('sound/voice/wraith/wraithwhisper1.ogg', 'sound/voice/wraith/wraithwhisper3.ogg')
	. = ..()


/datum/speech_module/output/wraithchat/poltergeist
	id = SPEECH_OUTPUT_WRAITHCHAT_POLTERGEIST
	priority = SPEECH_OUTPUT_PRIORITY_HIGH
	role = "Poltergeist"


/datum/speech_module/output/wraithchat/plague_rat
	id = SPEECH_OUTPUT_WRAITHCHAT_PLAGUE_RAT
	priority = SPEECH_OUTPUT_PRIORITY_HIGH
	role = "Rat"


/datum/speech_module/output/wraithchat/wraith_summon
	id = SPEECH_OUTPUT_WRAITHCHAT_WRAITH_SUMMON
	priority = SPEECH_OUTPUT_PRIORITY_HIGH
	role = "Summon"


/datum/speech_module/output/wraithchat/admin
	id = SPEECH_OUTPUT_WRAITHCHAT_ADMIN
	speech_prefix = null
