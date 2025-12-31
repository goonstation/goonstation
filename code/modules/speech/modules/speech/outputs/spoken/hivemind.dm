/datum/speech_module/output/spoken/hivemind
	id = SPEECH_OUTPUT_SPOKEN_HIVEMIND

/datum/speech_module/output/spoken/hivemind/format(datum/say_message/message)
	. = ..()

	var/mob/dead/target_observer/hivemind_observer/mob_speaker = message.speaker
	if (!istype(mob_speaker))
		return

	message.message_size_override = "6px"
	message.maptext_css_values["color"] = living_maptext_color(message.speaker.name)
	message.maptext_variables["maptext_x"] += prob(50) ? 28 : -28
	message.maptext_variables["maptext_y"] -= rand(12, 24)

	message.message_origin = mob_speaker.target
	message.speaker_to_display = "[pick("Congealed", "Subsumed", "Absorbed")] [mob_speaker]"
