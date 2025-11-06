/datum/speech_module/output/spoken/hivemind
	id = SPEECH_OUTPUT_SPOKEN_HIVEMIND

/datum/speech_module/output/spoken/hivemind/format(datum/say_message/message)
	. = ..()

	var/mob/dead/target_observer/hivemind_observer/mob_speaker = message.speaker
	if (!istype(mob_speaker))
		return

	message.message_origin = mob_speaker.target
	message.speaker_to_display = "Congealed [mob_speaker]"
