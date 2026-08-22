/datum/speech_module/modifier/ai_intercom
	id = SPEECH_MODIFIER_AI_INTERCOM_RADIO
	priority = SPEECH_MODIFIER_PRIORITY_VERY_LOW

/datum/speech_module/modifier/ai_intercom/process(datum/say_message/message)
	. = message

	// Restrict this behaviour to radio messages.
	if (!(message.relay_flags & SAY_RELAY_RADIO))
		return

	var/mob/living/silicon/ai/mainframe = src.parent_tree.speaker_parent.loc
	if (!istype(mainframe) || ((message.original_speaker != mainframe) && (message.original_speaker != mainframe.eyecam)))
		return

	var/datum/statusEffect/ai_intercom_override/status = mainframe.hasStatus("ai_intercom_override") || mainframe.eyecam?.hasStatus("ai_intercom_override")
	if (!istype(status))
		return

	message.flags &= ~SAYFLAG_NO_MAPTEXT
	message.maptext_origin = status.intercom
