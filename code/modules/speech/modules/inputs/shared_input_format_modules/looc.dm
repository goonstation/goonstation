/datum/shared_input_format_module/ooc/looc
	id = LISTEN_INPUT_LOOC

/datum/shared_input_format_module/ooc/looc/process(datum/say_message/message)
	. = ..()

	if (!ismob(message.speaker))
		return

	var/mob/mob_speaker = message.speaker
	if (!mob_speaker.client)
		return

	// Handle LOOC maptext colouration:
	message.maptext_prefix = "\[LOOC: "
	message.maptext_suffix = "]"

	if (mob_speaker.client.holder && (!mob_speaker.client.stealth || src.is_admin))
		if (mob_speaker.client.holder.level == LEVEL_BABBY)
			message.maptext_css_values["color"] = "#4cb7db"
		else
			message.maptext_css_values["color"] = "#cd6c4c"

	else if (mob_speaker.client.is_mentor() && !mob_speaker.client.stealth)
		message.maptext_css_values["color"] = "#a24cff"

	else if (mob_speaker.client.player.is_newbee)
		message.maptext_css_values["color"] = "#8BC16E"

	else
		message.maptext_css_values["color"] = "#ffffff"

/datum/shared_input_format_module/ooc/looc/render_message(datum/say_message/message, mob/mob_speaker, rendered_ooc_icon, ooc_class)
	if (ooc_class)
		ooc_class += "looc"

	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS
	message.flags |= SAYFLAG_NO_SAY_VERB

	message.format_speaker_prefix = {"\
		[rendered_ooc_icon]\
		<span class='looc [ooc_class]'>\
			<span class='prefix'>LOOC: </span>\
			<span class='name' data-ctx='\ref[mob_speaker.mind]'>\
	"}

	message.format_verb_prefix = {"\
		:</span> \
	"}

	message.format_content_prefix = {"\
		<span class='message'>\
	"}

	message.format_content_suffix = {"\
		</span></span>\
	"}


/datum/shared_input_format_module/ooc/looc/admin
	id = LISTEN_INPUT_LOOC_ADMIN_LOCAL
	is_admin = TRUE


/datum/shared_input_format_module/ooc/looc/admin/admin_global
	id = LISTEN_INPUT_LOOC_ADMIN_GLOBAL
