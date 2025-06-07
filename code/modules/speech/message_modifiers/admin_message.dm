/datum/message_modifier/postprocessing/admin_message
	sayflag = SAYFLAG_ADMIN_MESSAGE

/datum/message_modifier/postprocessing/admin_message/process(datum/say_message/message)
	. = message

	var/mob/mob_speaker = message.original_speaker
	if (!istype(mob_speaker) || !mob_speaker.client)
		return

	var/client/speaker_client = mob_speaker.client
	var/show_other_key = speaker_client.stealth || speaker_client.alt_key

	var/mob/mob_listener = message.received_module.parent_tree.listener_parent
	if (istype(mob_listener) && mob_listener.client?.holder && !mob_listener.client.player_mode)
		if (show_other_key)
			message.speaker_to_display = "<b>ADMIN(</b>[speaker_client.key] (as [speaker_client.fakekey])<b>)</b>"
		else
			message.speaker_to_display = "<b>ADMIN(</b>[speaker_client.key]<b>)</b>"

	else
		if (show_other_key)
			message.speaker_to_display = "<b>ADMIN(</b>[speaker_client.fakekey]<b>)</b>"
		else
			message.speaker_to_display = "<b>ADMIN(</b>[speaker_client.key]<b>)</b>"
