/datum/speech_module/output/spoken
	id = SPEECH_OUTPUT_SPOKEN
	channel = SAY_CHANNEL_OUTLOUD
	var/send_to_global = TRUE

/datum/speech_module/output/spoken/process(datum/say_message/message)
	if (ismob(message.speaker))
		var/mob/M = message.speaker
		if (M.stat != STAT_ALIVE)
			return

	src.format(message)

	if (isliving(message.speaker))
		var/mob/living/M = message.speaker
		M.last_words = message.content

	if (!src.send_to_global)
		message.flags |= SAYFLAG_DELIMITED_CHANNEL_ONLY

	global.SpeechManager.ProcessMessagePrefix(message, src.parent_tree)

	. = ..()

/datum/speech_module/output/spoken/proc/format(datum/say_message/message)
	// Create a text reference to the speaker's mind, if they have one.
	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.speaker_to_display ||= message.get_speaker_name()

	message.format_speaker_prefix = {"\
		<span class='name' data-ctx='[mind_ref]'>\
		<b>\
	"}

	message.format_verb_prefix = {"\
		</b></span> \
		<span class='message'>\
	"}

	message.format_content_prefix = {"\
		, \
	"}

	message.format_message_suffix = {"\
		</span>\
	"}
