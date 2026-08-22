/datum/listen_module/modifier/ai_intercom_maptext
	id = LISTEN_MODIFIER_AI_INTERCOM_MAPTEXT

/datum/listen_module/modifier/ai_intercom_maptext/process(datum/say_message/message)
	. = message

	// Restrict this behaviour to radio messages.
	if (!(message.relay_flags & SAY_RELAY_RADIO))
		return

	if (message.original_speaker == src.parent_tree.listener_parent)
		return

	message.flags &= ~SAYFLAG_NO_MAPTEXT
	message.maptext_origin ||= message.original_speaker
