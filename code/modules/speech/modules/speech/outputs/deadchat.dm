/datum/speech_module/output/deadchat
	id = SPEECH_OUTPUT_DEADCHAT
	priority = SPEECH_OUTPUT_PRIORITY_DEFAULT
	channel = SAY_CHANNEL_DEAD
	speech_prefix = SPEECH_PREFIX_DEADCHAT
	var/role = null

/datum/speech_module/output/deadchat/process(datum/say_message/message)
	var/maptext_colour = dead_maptext_color(message.speaker.name)

	message.maptext_css_values["color"] = maptext_colour
	message.maptext_animation_colours = list(
		maptext_colour,
		"#c482d1",
	)

	message.say_verb = pick(
		32; "moans",
		32; "wails",
		32; "laments",
		4; "grumps",
	)

	if (src.role)
		message.speaker_to_display = "([message.real_ident])"

	else if (ishuman(message.speaker) && (message.face_ident != message.real_ident))
		if (message.card_ident && (message.card_ident != message.real_ident))
			message.speaker_to_display = "[message.real_ident] (as [message.card_ident])"
		else if (!message.card_ident)
			message.speaker_to_display = "[message.real_ident] (as Unknown)"

	else
		message.speaker_to_display = message.real_ident

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game deadsay'>\
			<span class='prefix'>DEAD: </span>\
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


/datum/speech_module/output/deadchat/ghost
	id = SPEECH_OUTPUT_DEADCHAT_GHOST
	priority = SPEECH_OUTPUT_PRIORITY_HIGH
	role = "Ghost"


/datum/speech_module/output/deadchat/poltergeist
	id = SPEECH_OUTPUT_DEADCHAT_POLTERGEIST
	priority = SPEECH_OUTPUT_PRIORITY_HIGH
	role = "Poltergeist"


/datum/speech_module/output/deadchat/wraith
	id = SPEECH_OUTPUT_DEADCHAT_WRAITH
	priority = SPEECH_OUTPUT_PRIORITY_HIGH
	role = "Wraith"


/datum/speech_module/output/deadchat_announcer
	id = SPEECH_OUTPUT_DEADCHAT_ANNOUNCER
	channel = SAY_CHANNEL_DEAD

/datum/speech_module/output/deadchat_announcer/process(datum/say_message/message)
	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS
	message.speaker_to_display = ""
	message.say_verb = ""

	message.format_speaker_prefix = {"\
		<span class='game deadsay'>\
	"}

	message.format_verb_prefix = ""
	message.format_content_prefix = ""

	message.format_content_suffix = {"\
		</span>\
	"}

	. = ..()


/datum/speech_module/output/deadchat/admin
	id = SPEECH_OUTPUT_DEADCHAT_ADMIN
	speech_prefix = null
