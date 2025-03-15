/datum/speech_module/output/mentor_mouse
	id = SPEECH_OUTPUT_MENTOR_MOUSE
	channel = SAY_CHANNEL_MENTOR_MOUSE

/datum/speech_module/output/mentor_mouse/process(datum/say_message/message)
	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.say_verb = "whispers"
	message.flags |= SAYFLAG_NO_MAPTEXT | SAYFLAG_DO_NOT_PASS_TO_IMPORTING_TREES

	// Handles mentor/admin mouse speech, since they are just rebranded mentor mice
	var/ooc_flavor = "mhelp"
	if (istype(message.speaker, /mob/dead/target_observer/mentor_mouse_observer))
		var/mob/dead/target_observer/mentor_mouse_observer/mentor_mouse = message.speaker
		message.hear_sound = 'sound/misc/mentorhelp.ogg'
		message.atom_listeners_override = list(mentor_mouse, mentor_mouse.mentee)
		if (mentor_mouse.is_admin)
			ooc_flavor = "adminooc"

	message.format_speaker_prefix = {"\
		<span class='game [ooc_flavor]'>\
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
