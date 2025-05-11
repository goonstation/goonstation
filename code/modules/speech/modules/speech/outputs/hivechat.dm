/datum/speech_module/output/bundled/hivemind
	id = SPEECH_OUTPUT_HIVECHAT
	channel = SAY_CHANNEL_HIVEMIND
	var/role = ""

/datum/speech_module/output/bundled/hivemind/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game hivesay'>\
			<span class='prefix'>HIVEMIND: </span>\
			<span class='name' data-ctx='[mind_ref]'>\
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


/datum/speech_module/output/bundled/hivemind/member
	id = SPEECH_OUTPUT_HIVECHAT_MEMBER

/datum/speech_module/output/bundled/hivemind/member/process(datum/say_message/message)
	src.role = ""

	if (!ismob(message.speaker))
		return

	var/mob/mob_speaker = message.speaker
	var/datum/abilityHolder/changeling/changeling_ability_holder = locate(src.subchannel)

	if (!changeling_ability_holder)
		return

	// Standard behaviour, where the changeling master is in control.
	if (!changeling_ability_holder.master)
		if (mob_speaker == changeling_ability_holder.owner)
			src.role = " (MASTER)"

	// A member of the hivemind is in control.
	else
		if (mob_speaker == changeling_ability_holder.owner)
			src.role = " (CONTROLLER)"

		else if (mob_speaker == changeling_ability_holder.master)
			src.role = " (MASTER)"

	if (isabomination(changeling_ability_holder.owner) && istype(message.speaker, /mob/dead/target_observer/hivemind_observer))
		changeling_ability_holder.owner.say(message.content, flags = 0, message_params = list("speaker_to_display" = "Congealed [message.speaker]"))

	. = ..()


/datum/speech_module/output/bundled/hivemind/handspider
	id = SPEECH_OUTPUT_HIVECHAT_HANDSPIDER
	role = " (HANDSPIDER)"


/datum/speech_module/output/bundled/hivemind/eyespider
	id = SPEECH_OUTPUT_HIVECHAT_EYESPIDER
	role = " (EYESPIDER)"


/datum/speech_module/output/bundled/hivemind/legworm
	id = SPEECH_OUTPUT_HIVECHAT_LEGWORM
	role = " (LEGWORM)"


/datum/speech_module/output/bundled/hivemind/buttcrab
	id = SPEECH_OUTPUT_HIVECHAT_BUTTCRAB
	role = " (BUTTCRAB)"


/datum/speech_module/output/global_hivemind
	id = SPEECH_OUTPUT_HIVECHAT_GLOBAL
	channel = SAY_CHANNEL_GLOBAL_HIVEMIND

/datum/speech_module/output/global_hivemind/process(datum/say_message/message)
	message.flags |= SAYFLAG_NO_MAPTEXT

	var/mind_ref = ""
	if (ismob(message.speaker))
		var/mob/mob_speaker = message.speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.format_speaker_prefix = {"\
		<span class='game hivesay'>\
			<span class='prefix'>HIVEMIND: </span>\
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
