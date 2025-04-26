var/regex/forbidden_character_regex = regex(@"[\u2028\u202a\u202b\u202c\u202d\u202e]", "g")

/**
 *	The base message type; it contains the content of a message and all of the relevant metadata. Any text that has been passed
 *	to `say()` is in turn passed into a new say message datum.
 */
/datum/say_message
	// Message Content & Format Variables:
	/// The name of the speaker that should be used when displaying the message to a listener. If null, defaults to the `speaker` atom.
	var/speaker_to_display = null
	/// The text indicating where this message was spoken from, if it was spoken from inside of an object.
	var/speaker_location_text = null
	/// The sanitised and processed content of this message.
	var/content = ""
	/// The verb to display when this message is received, i.e: "Jeff [say_verb], [message]"
	var/say_verb = null
	/// The verb to display when this message is received, if it is whispered.
	var/whisper_verb = "whispers"
	/// The formatting that should immediately precede `speaker_to_display`.
	var/format_speaker_prefix = ""
	/// The formatting that should immediately follow `speaker_to_display` and precede `say_verb`.
	var/format_verb_prefix = ""
	/// The formatting that should immediately follow `say_verb` and precede `format_content_style_prefix`.
	var/format_content_prefix = ""
	/// The formatting that should immediately follow `format_content_prefix` and precede `content`. Will be grouped with `content` in maptext.
	var/format_content_style_prefix = ""
	/// The formatting that should immediately follow `content` and precede `format_content_suffix`. Will be grouped with `content` in maptext.
	var/format_content_style_suffix = ""
	/// The formatting that should immediately follow `format_content_style_suffix`.
	var/format_content_suffix = ""

	// Speaker Identification Variables:
	/// The atom that sent this message.
	var/atom/speaker = null
	/// The atom that originally sent this message.
	var/atom/original_speaker = null
	/// The atom that should appear to have sent this message.
	var/atom/message_origin = null
	/// The voice identity of the speaker.
	var/voice_ident = null
	/// The facial identity of the speaker.
	var/face_ident = null
	/// The worn identity of the speaker, if they have one.
	var/card_ident = null
	/// The real name of the speaker.
	var/real_ident = null

	// Message Information Variables:
	/// The non-unique ID of this message. A listener may only hear one message of a specific ID at any time.
	var/id = ""
	/// The datum that should act as a signal recipient for every copy of this message.
	var/datum/signal_recipient = null
	/// The original contents of this message, uneditied, unsanitised.
	var/original_content = ""
	/// Message flags. See `_std/defines/speech_defines/sayflags.dm`.
	var/flags = SAYFLAG_HAS_QUOTATION_MARKS
	/// The sound that should play when this message is spoken.
	var/say_sound = null
	/// The sound that should be played to listeners when this message is heard.
	var/hear_sound = null
	/// The language that this message was sent in.
	var/datum/language/language = null
	/// The range of a heard message.
	var/heard_range = DEFAULT_HEARING_RANGE
	/// How loud a message is determines how large it is displayed in the text window.
	var/loudness = 0
	/// If set, overrides the `loudness` variable, and sets the font size of the message to the set value.
	var/message_size_override = null
	/// The radio prefix that this message was sent with.
	var/prefix = ""
	/// The last character of this message. Used to determine messages intonation, i.e: "?" will result in a message being treated as a question.
	var/last_character = ""
	/// The channel that this radio message should attempt to be sent on. If `null`, will be sent to all available outputs.
	var/output_module_channel = null
	/// If set, the output module that this message should attempt to be passed to.
	var/output_module_override = null
	/// The input module that received this message last.
	var/datum/listen_module/input/received_module = null
	/// If set, this say message datum will be sent to these atoms as opposed to being broadcast over a say channel.
	var/list/atom/atom_listeners_override = null
	/// If set, and `atom_listeners_override` is not set, this say message datum will not be send to the atoms in this list when being broadcast over a say channel. Note that this is an associative list.
	var/list/atom/atom_listeners_to_be_excluded = null
	/// A bitflag of the various way that this message has been retransmitted. Used to prevent feedback loops.
	var/relay_flags = null
	/// If FALSE, this message will not be permitted to be retransmitted, regardless of the flags present in `relay_flags`.
	var/can_relay = TRUE

	// Maptext Variables:
	/// The CSS values for the maptext, stored as an associative list, i.e: "font-weight" = "bold".
	var/list/maptext_css_values = null
	/// The variables for the maptext object, stored as an associative list, i.e: "alpha" = "140".
	var/list/maptext_variables = list(
		"alpha" = 255,
		"maptext_x" = -64,
		"maptext_y" = 34,
		"maptext_width" = 160,
		"maptext_height" = 48,
	)
	/// A list of colours for the maptext to oscillate through. Use the "start_colour" value to determine the colour to animate from to `maptext_css_values["color"]`.
	var/list/maptext_animation_colours = null
	/// A prefix that should only be displayed on the maptext.
	var/maptext_prefix = null
	/// A suffix that should only be displayed on the maptext.
	var/maptext_suffix = null

/datum/say_message/New(message as text, atom/speaker, flags, list/message_params = null, atom_listeners_override = null, is_copy = FALSE)
	. = ..()

	// If this say message datum is a copy, there is no need to run the code below as var information will be copied to this datum.
	if (is_copy)
		return

	src.original_content = message
	src.content = message
	src.speaker = speaker.speech_tree.speaker_parent
	src.original_speaker = speaker.speech_tree.speaker_parent
	src.message_origin = speaker.speech_tree.speaker_origin
	src.id = "\ref[src]"
	src.flags |= flags
	src.atom_listeners_override = atom_listeners_override
	src.maptext_css_values = list()

	// Determine identification variables and the say verb to use.
	src.last_character = copytext(src.content, length(src.content))
	switch (src.last_character)
		if ("?")
			src.say_verb = speaker.speech_verb_ask
		if ("!")
			src.say_verb = speaker.speech_verb_exclaim

	if (ismob(speaker))
		var/mob/mob_speaker = speaker
		if (ishuman(mob_speaker))
			var/mob/living/carbon/human/H = mob_speaker
			src.say_verb ||= H.mutantrace.say_verb()
			src.voice_ident = H.mutantrace.voice_name || H.voice_name
		else
			src.voice_ident = mob_speaker.voice_name

		src.face_ident = mob_speaker.name
		src.real_ident = mob_speaker.real_name
	else
		src.voice_ident = speaker.name
		src.face_ident = speaker.name
		src.real_ident = speaker.name

	src.say_verb ||= speaker.speech_verb_say

	// A deplorably disgusting hack to get `card_ident`.
	if (hasvar(speaker, "wear_id"))
		src.card_ident = speaker:wear_id?:registered

	// Apply the variable overrides passed in the message parameters.
	for (var/variable_name in message_params)
		if (!issaved(src.vars[variable_name]))
			continue

		src.vars[variable_name] = message_params[variable_name]

	// Attempt to assign a language.
	if (!istype(src.language))
		src.language = global.SpeechManager.GetLanguageInstance(src.speaker.say_language)

	// Determine whether this message has a radio prefix, and adjust the content accordingly.
	if (length(src.content) >= 2)
		var/cut_position = 0

		switch (copytext(src.content, 1, 2))
			if (";")
				cut_position = 2
			if (":")
				cut_position = findtext(src.content, " ", 1) + 1

		if (cut_position)
			src.prefix = lowertext(trimtext(copytext(src.content, 1, cut_position)))
			src.content = copytext(src.content, cut_position, MAX_MESSAGE_LEN)

	src.content = src.make_safe_for_chat(src.content)

	// Determine whether this message has a singing prefix, and adjust the content accordingly.
	if (copytext(src.content, 1, 2) == "%")
		src.flags |= SAYFLAG_SINGING
		src.content = trimtext(copytext(src.content, 2, MAX_MESSAGE_LEN))
		src.say_verb = "sings"

	// Ensure that a channel is assigned to this message.
	src.output_module_channel ||= src.speaker.default_speech_output_channel

	if (ismob(src.speaker))
		src.run_mob_and_client_checks()

/datum/say_message/disposing()
	src.speaker = null
	src.original_speaker = null
	src.message_origin = null
	src.signal_recipient = null
	src.language = null
	src.received_module = null
	src.atom_listeners_override = null
	src.atom_listeners_to_be_excluded = null

	. = ..()

/// Removes forbidden characters, newlines, tabs, and HTML tags from a message, and checks for URLs.
/datum/say_message/proc/make_safe_for_chat(message as text)
	// Remove forbidden characters that break the text or worse.
	message = replacetext(message, global.forbidden_character_regex, "")
	// Remove newline and tab characters.
	message = sanitize(message)
	// Limit the length of the message.
	message = copytext(message, 1, MAX_MESSAGE_LEN)
	// Remove forbidden ASCII characters and whitespace from the beginning and end.
	message = trimtext(message)
	// Remove HTML tags.
	if (!(src.flags & SAYFLAG_IGNORE_HTML))
		message = strip_html(message)

		// Check for URLs.
		if (global.url_regex.Find(message))
			if (ismob(src.speaker))
				boutput(src.speaker, "<span class='notice'><b>Web/BYOND links are not allowed in ingame chat.</b></span>")
			return

	return message

/// Checks whether the mob or client is muted, and applies preference data to the message's content.
/datum/say_message/proc/run_mob_and_client_checks()
	var/mob/M = src.original_speaker
	if (M.client)
		if (M.client.ismuted())
			boutput(M, "You are currently muted and may not speak.")
			qdel(src)
			return

		if (M.client.preferences?.auto_capitalization)
			src.content = capitalize(src.content)

#ifdef DATALOGGER
		if (src.flags & SAYFLAG_SPOKEN_BY_PLAYER)
			global.game_stats.ScanText(src.content)
#endif

/// Determines the say sound that this message should use, and plays it.
/datum/say_message/proc/process_say_sound()
	if (world.time < src.speaker.last_voice_sound + VOICE_SOUND_COOLDOWN)
		return

	if (src.say_sound == NO_SAY_SOUND)
		return

	if (!src.say_sound && !src.speaker.voice_type && !src.speaker.voice_sound_override)
		return

	src.say_sound ||= src.speaker.voice_sound_override

	if (!src.say_sound)
		var/voice_type = src.speaker.voice_type

		switch (src.last_character)
			if ("?")
				voice_type = "[voice_type]?"
			if ("!")
				voice_type = "[voice_type]!"

		src.say_sound = global.sounds_speak["[voice_type]"]

	var/voice_pitch = src.speaker.voice_pitch
	if (ismob(src.speaker))
		var/mob/mob_speaker = src.speaker
		voice_pitch = mob_speaker.get_age_pitch_for_talk()

	if (islist(src.say_sound))
		src.say_sound = pick(src.say_sound)

	src.speaker.last_voice_sound = world.time
	playsound(src.speaker, src.say_sound, 55, 0.01, 8, voice_pitch, ignore_flag = SOUND_SPEECH)

/// Determines the speech bubble that this message should use, and displays it on the speaker.
/datum/say_message/proc/process_speech_bubble()
	if (!src.speaker.use_speech_bubble)
		return

	var/speech_bubble_icon
	if (src.flags & (SAYFLAG_BAD_SINGING | SAYFLAG_LOUD_SINGING))
		speech_bubble_icon = src.speaker.speech_bubble_icon_sing_bad

	else if (src.flags & SAYFLAG_SINGING)
		speech_bubble_icon = src.speaker.speech_bubble_icon_sing

	else switch (src.last_character)
		if ("?")
			speech_bubble_icon = src.speaker.speech_bubble_icon_ask
		if ("!")
			speech_bubble_icon = src.speaker.speech_bubble_icon_exclaim
		else
			var/number = text2num(src.content)
			if (number && (((number >= 0) && (number <= 20)) || number == 420))
				speech_bubble_icon = "[number]"

	speech_bubble_icon ||= src.speaker.speech_bubble_icon_say
	src.message_origin.speech_bubble.icon_state = speech_bubble_icon
	src.message_origin.show_speech_bubble()

/// Returns a formatted message for use with `boutput()`, using either the last listen input module or falling back to the default format of `"[speaker] [say_verb], [content]"`.
/datum/say_message/proc/format_for_output(atom/listener)
	// Apply any message modifier flags to the message.
	global.SpeechManager.ApplyMessageModifierPostprocessing(src)

	// Apply loudness effects.
	if (!isnull(src.message_size_override))
		src.format_speaker_prefix = "<font size=[src.message_size_override]>" + src.format_speaker_prefix
		src.format_content_suffix += "</font>"
		src.maptext_css_values["font-size"] ||= message_size_override
	else if (src.loudness > 1) // Very loud.
		src.format_speaker_prefix = "<strong style='font-size:36px'><b>" + src.format_speaker_prefix
		src.format_content_suffix += "</b></strong>"
	else if (src.loudness == 1) // Loud.
		src.format_speaker_prefix = "<big><strong><b>" + src.format_speaker_prefix
		src.format_content_suffix += "</b></strong></big>"
	else if (src.loudness < 0) // Quiet.
		src.format_speaker_prefix = "<small>" + src.format_speaker_prefix
		src.format_content_suffix += "</small>"

	var/mob/mob_listener = listener
	if (istype(mob_listener) && mob_listener.client)
		// Display maptext to the listener, if applicable.
		if (!(src.flags & SAYFLAG_NO_MAPTEXT) && !mob_listener.client.preferences.flying_chat_hidden)
			src.maptext_css_values["color"] ||= living_maptext_color(src.speaker.name)
			src.message_origin.maptext_manager ||= new /atom/movable/maptext_manager(src.message_origin)
			src.message_origin.maptext_manager.add_maptext(mob_listener.client, global.message_maptext(src))

		/// Handle hear sounds.
		if (src.hear_sound && !src.received_module.say_channel.suppress_hear_sound)
			mob_listener.playsound_local_not_inworld(src.hear_sound, 55, 0.01, flags = SOUND_IGNORE_SPACE)

	// If the speaker to display is null, use the real name of the speaker instead.
	if (isnull(src.speaker_to_display))
		src.speaker_to_display = src.real_ident || src.face_ident

	// If there is location text to display, append it to the speaker name.
	if (src.speaker_location_text)
		src.speaker_to_display += " [src.speaker_location_text]"

	// If `say_verb` is a list, pick a string from that list to use as a verb.
	if (islist(src.say_verb))
		src.say_verb = pick(src.say_verb)

	return {"\
		[src.format_speaker_prefix]\
		[src.speaker_to_display]\
		[src.format_verb_prefix]\
		[src.say_verb]\
		[src.format_content_prefix]\
		[src.format_content_style_prefix]\
		[src.content]\
		[src.format_content_style_suffix]\
		[src.format_content_suffix]\
	"}
/// Returns the heard name of the speaker, taking into account masks, voice changers, and IDs.
/datum/say_message/proc/get_speaker_name(heard_name_only = FALSE)
	if (!ismob(src.speaker))
		return src.speaker.name

	var/mob/M = src.speaker

	// The speaker is using a voice changer.
	if (M.wear_mask?.vchange)
		if (!isnull(src.card_ident))
			return src.card_ident

		return "Unknown"

	// The speaker is vocally disfigured.
	if (M.vdisfigured)
		return "Unknown"

	// The speaker's displayed name does not match their real name.
	if (!heard_name_only && (M.name != M.real_name))
		if (isnull(src.card_ident))
			return "[M.real_name] (as Unknown)"

		if (src.card_ident != M.real_name)
			return "[M.real_name] (as [src.card_ident])"

	return M.real_name

/// Create a copy of this say message datum.
/datum/say_message/proc/Copy()
	RETURN_TYPE(/datum/say_message)

	var/datum/say_message/copy = new(is_copy = TRUE)

	// Note that the below is ~5 times faster than a `for (var/V in src.vars)` loop.

	// Message Content & Format Variables:
	copy.speaker_to_display = src.speaker_to_display
	copy.speaker_location_text = src.speaker_location_text
	copy.content = src.content
	copy.say_verb = src.say_verb
	copy.whisper_verb = src.whisper_verb
	copy.format_speaker_prefix = src.format_speaker_prefix
	copy.format_verb_prefix = src.format_verb_prefix
	copy.format_content_prefix = src.format_content_prefix
	copy.format_content_style_prefix = src.format_content_style_prefix
	copy.format_content_style_suffix = src.format_content_style_suffix
	copy.format_content_suffix = src.format_content_suffix

	// Speaker Identification Variables:
	copy.speaker = src.speaker
	copy.original_speaker = src.original_speaker
	copy.message_origin = src.message_origin
	copy.voice_ident = src.voice_ident
	copy.face_ident = src.face_ident
	copy.card_ident = src.card_ident
	copy.real_ident = src.real_ident

	// Message Information Variables:
	copy.id = src.id
	copy.signal_recipient = src.signal_recipient
	copy.original_content = src.original_content
	copy.flags = src.flags
	copy.say_sound = src.say_sound
	copy.hear_sound = src.hear_sound
	copy.language = src.language
	copy.heard_range = src.heard_range
	copy.loudness = src.loudness
	copy.message_size_override = src.message_size_override
	copy.prefix = src.prefix
	copy.last_character = src.last_character
	copy.output_module_channel = src.output_module_channel
	copy.output_module_override = src.output_module_override
	copy.received_module = src.received_module
	copy.atom_listeners_override = src.atom_listeners_override?.Copy()
	copy.atom_listeners_to_be_excluded = src.atom_listeners_to_be_excluded?.Copy()
	copy.relay_flags = src.relay_flags
	copy.can_relay = src.can_relay

	// Maptext Variables:
	copy.maptext_css_values = src.maptext_css_values?.Copy()
	copy.maptext_variables = src.maptext_variables?.Copy()
	copy.maptext_animation_colours = src.maptext_animation_colours?.Copy()
	copy.maptext_prefix = src.maptext_prefix
	copy.maptext_suffix = src.maptext_suffix

	return copy
