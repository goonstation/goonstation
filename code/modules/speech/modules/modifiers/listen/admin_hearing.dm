/datum/listen_module/modifier/admin_hearing
	id = LISTEN_MODIFIER_ADMIN_HEARING
	override_say_channel_modifier_preference = TRUE

/datum/listen_module/modifier/admin_hearing/process(datum/say_message/message)
	. = message

	if (!ismob(src.parent_tree.listener_parent) || !ismob(message.original_speaker))
		return

	var/mob/mob_listener = src.parent_tree.listener_parent
	var/mob/mob_speaker = message.original_speaker

	if (!mob_listener.client?.holder || !mob_speaker.mind)
		return

	message.format_speaker_prefix = "<span class='adminHearing' data-ctx='[mob_listener.client.chatOutput.getContextFlags()]'>" + message.format_speaker_prefix
	message.format_content_suffix += "</span>"
