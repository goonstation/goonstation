/datum/shared_input_format_module/ooc
	id = LISTEN_INPUT_OOC
	var/is_admin = FALSE

/datum/shared_input_format_module/ooc/process(datum/say_message/message)
	. = message

	if (!ismob(message.speaker))
		return

	var/mob/mob_speaker = message.speaker
	if (!mob_speaker.client)
		return

	// Determine the displayed key of the speaker.
	message.speaker_to_display = mob_speaker.key
	if (mob_speaker.client.stealth || mob_speaker.client.alt_key)
		if (src.is_admin)
			message.speaker_to_display += " (as [mob_speaker.client.fakekey])"
		else
			message.speaker_to_display = mob_speaker.client.fakekey

	// Determine the CSS class and OOC icon of the speaker.
	var/ooc_class = ""
	var/ooc_icon
	if (mob_speaker.client.holder && (!mob_speaker.client.stealth || src.is_admin))
		if (mob_speaker.client.holder.level == LEVEL_BABBY)
			ooc_class = "gfart"
		else
			ooc_class = "admin"
			ooc_icon = "Admin"

	else if (mob_speaker.client.is_mentor() && !mob_speaker.client.stealth)
		ooc_class = "mentor"
		ooc_icon = "Mentor"

	else if (mob_speaker.client.player.is_newbee)
		ooc_class = "newbee"
		ooc_icon = "Newbee"

	// Permit donors and contest winners to use :shelterfrog: and :shelterbee: in OOC.
	if (mob_speaker.client.player?.cloudSaves.getData("donor"))
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(replacetext_wrapper), ":shelterfrog:", MAKE_CONTENT_IMMUTABLE("<img src='http://stuff.goonhub.com/shelterfrog.png' width=32>")))

	if (mob_speaker.client.has_contestwinner_medal)
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(replacetext_wrapper), ":shelterbee:", MAKE_CONTENT_IMMUTABLE("<img src='http://stuff.goonhub.com/shelterbee.png' width=32>")))

	var/rendered_ooc_icon = ""
	if (ooc_icon)
		rendered_ooc_icon = {"\
			<div class='tooltip'>\
				<img \
					class='icon misc' \
					style='position: relative; bottom: -3px; ' \
					src='[resource("images/radio_icons/[ooc_icon].png")]'\
				>\
				<span class='tooltiptext'>[ooc_icon]</span>\
			</div> \
		"}

	src.render_message(message, mob_speaker, rendered_ooc_icon, ooc_class)

/datum/shared_input_format_module/ooc/proc/render_message(datum/say_message/message, mob/mob_speaker, rendered_ooc_icon, ooc_class)
	if (ooc_class)
		ooc_class += "ooc"

	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS
	message.flags |= SAYFLAG_NO_SAY_VERB

	message.format_speaker_prefix = {"\
		[rendered_ooc_icon]\
		<span class='ooc [ooc_class]'>\
			<span class='prefix'>OOC: </span>\
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


/datum/shared_input_format_module/ooc/admin
	id = LISTEN_INPUT_OOC_ADMIN
	is_admin = TRUE
