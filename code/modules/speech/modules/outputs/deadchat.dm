/datum/speech_module/output/deadchat
	id = SPEECH_OUTPUT_DEADCHAT
	channel = SAY_CHANNEL_DEAD

/datum/speech_module/output/deadchat/process(datum/say_message/message)
	var/num = hex2num(copytext(md5(message.speaker.name), 1, 7))
	var/maptext_colour = hsv2rgb((num % 360) % 40 + 240, (num / 360) % 15 + 5, (num / 3600) % 15 + 55)

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

	var/role = ""

	if (ishuman(message.speaker) && (message.face_ident != message.real_ident))
		if (message.card_ident && (message.card_ident != message.real_ident))
			message.speaker_to_display = "[message.real_ident] (as [message.card_ident])"
		else if (!message.card_ident)
			message.speaker_to_display = "[message.real_ident] (as Unknown)"

	else if (isobserver(message.speaker))
		role = "Ghost"
		message.speaker_to_display = "([message.real_ident])"

	else if (ispoltergeist(message.speaker))
		role = "Poltergeist"
		message.speaker_to_display = "([message.real_ident])"

	else if (iswraith(message.speaker))
		role = "Wraith"
		message.speaker_to_display = "([message.real_ident])"

	else
		message.speaker_to_display = message.real_ident

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game deadsay'>\
			<span class='prefix'>DEAD: </span>\
			<span class='name' data-ctx='[mind_ref]'>[role]<span class='text-normal'> \
	"}

	message.format_verb_prefix = {"\
		</span></span> \
		<span class='message'>\
	"}

	message.format_content_prefix = {"\
		, \
	"}

	message.format_message_suffix = {"\
		</span></span>\
	"}

	. = ..()
