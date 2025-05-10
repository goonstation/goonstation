/datum/speech_module/output/bundled/flock_say
	id = SPEECH_OUTPUT_FLOCK
	channel = SAY_CHANNEL_FLOCK
	var/datum/flock/flock
	var/datum/say_channel/distorted_flock/distorted_flock_channel

/datum/speech_module/output/bundled/flock_say/New(datum/speech_module_tree/parent, subchannel, datum/flock/flock)
	. = ..()

	src.flock = flock
	src.distorted_flock_channel = global.SpeechManager.GetSayChannelInstance(SAY_CHANNEL_FLOCK_DISTORTED)

/datum/speech_module/output/bundled/flock_say/process(datum/say_message/message)
	var/list/style = src.get_styling(message)
	var/mind_ref = style["mind_ref"]
	var/classes = style["classes"]

	message.format_speaker_prefix = {"\
		<span class='game [classes]'>\
			<span class='bold'>\[[src.flock ? src.flock.name : "--.--"]\] </span>\
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

	if (!src.flock.flockmind?.tutorial && (src.flock.total_compute() >= FLOCK_RELAY_COMPUTE_COST / 4) && (ismob(message.speaker) || prob(30)) && (message.flags & SAYFLAG_SPOKEN_BY_PLAYER) && prob(90))
		var/datum/say_message/distorted_message = message.Copy()
		distorted_message.format_speaker_prefix = {"\
			<span class='game [classes]'>\
				<span class='bold'>\[?????\] </span>\
				<span class='name' data-ctx='[mind_ref]'>\
		"}
		distorted_message.speaker_to_display = radioGarbleText(distorted_message.speaker_to_display, FLOCK_RADIO_GARBLE_CHANCE)
		distorted_message.content = radioGarbleText(distorted_message.content, FLOCK_RADIO_GARBLE_CHANCE)

		PASS_MESSAGE_TO_SAY_CHANNEL(src.distorted_flock_channel, distorted_message)

	. = ..()

/datum/speech_module/output/bundled/flock_say/proc/get_styling(datum/say_message/message)
	var/mind_ref = ""
	var/classes = "flocksay"

	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

		if (istype(mob_speaker, /mob/living/critter/flock/drone))
			var/mob/living/critter/flock/drone/F = mob_speaker
			if (F.is_npc)
				message.speaker_to_display = "Drone [F.real_name]"
				classes += " flocknpc"

			else if (F.controller)
				message.speaker_to_display = "[F.controller.real_name]"
				if (istype(F.controller, /mob/living/intangible/flock))
					mob_speaker = F.controller

		else if (istype(mob_speaker, /mob/living/intangible/flock) && (message.flags & SAYFLAG_SPOKEN_BY_PLAYER))
			classes += " sentient"
			if (istype(mob_speaker, /mob/living/intangible/flock/flockmind))
				classes += " flockmind"

		else
			message.speaker_to_display = mob_speaker.real_name

	if (isnull(message.speaker_to_display))
		message.speaker_to_display = message.real_ident

	return list(
		"classes" = "[classes]",
		"mind_ref" = "[mind_ref]",
	)


/datum/speech_module/output/bundled/flock_say/system
	id = SPEECH_OUTPUT_FLOCK_SYSTEM
	channel = SAY_CHANNEL_FLOCK

/datum/speech_module/output/bundled/flock_say/system/process(datum/say_message/message)
	if (src.flock.quiet)
		return

	. = ..()

/datum/speech_module/output/bundled/flock_say/system/get_styling(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT
	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS
	message.speaker_to_display = "\[SYSTEM\]"
	message.say_verb = "alerts"
	message.content = gradientText("#3cb5a3", "#124e43", "\"[message.content]\"")

	return list(
		"classes" = "flocksay bold italics",
		"mind_ref" = "",
	)


/datum/speech_module/output/global_flock
	id = SPEECH_OUTPUT_FLOCK_GLOBAL
	channel = SAY_CHANNEL_GLOBAL_FLOCK

/datum/speech_module/output/global_flock/process(datum/say_message/message)
	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.say_verb = "informs"

	message.format_speaker_prefix = {"\
		<span class='game flocksay sentient'>\
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


/datum/speech_module/output/ion_flock
	id = SPEECH_OUTPUT_FLOCK_ION
	channel = SAY_CHANNEL_FLOCK_DISTORTED

/datum/speech_module/output/ion_flock/process(datum/say_message/message)
	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.speaker_to_display ||= message.speaker.name
	message.speaker_to_display = radioGarbleText(message.speaker_to_display, FLOCK_RADIO_GARBLE_CHANCE)
	message.content = radioGarbleText(message.content, FLOCK_RADIO_GARBLE_CHANCE)

	message.format_speaker_prefix = {"\
		<span class='game flocksay sentient'>\
			<span class='bold'>\[?????\] </span>\
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
