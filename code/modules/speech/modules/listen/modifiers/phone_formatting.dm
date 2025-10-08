/datum/listen_module/modifier/phone
	id = LISTEN_MODIFIER_PHONE

/datum/listen_module/modifier/phone/process(datum/say_message/message)
	// If this message has already been relayed by a phone, don't receive it.
	if (!CAN_RELAY_MESSAGE(message, SAY_RELAY_PHONE))
		return NO_MESSAGE

	. = message

	var/obj/item/phone_handset/handset = src.parent_tree.listener_parent
	if (!istype(handset))
		return

	message.flags |= SAYFLAG_NO_MAPTEXT
	message.flags &= ~(SAYFLAG_WHISPER | SAYFLAG_NO_SAY_VERB)
	message.heard_range = 0
	message.output_module_channel = SAY_CHANNEL_OUTLOUD
	message.atom_listeners_override = null
	message.atom_listeners_to_be_excluded = null
	FORMAT_MESSAGE_FOR_RELAY(message, SAY_RELAY_PHONE)

	// Create a text reference to the speaker's mind, if they have one.
	var/mind_ref = ""
	if (ismob(message.original_speaker))
		var/mob/mob_speaker = message.original_speaker
		mind_ref = "\ref[mob_speaker.mind]"

	message.speaker_to_display ||= message.get_speaker_name(TRUE)

	message.format_speaker_prefix = {"\
		<span class='name' data-ctx='[mind_ref]'>\
		<b>\
	"}

	message.format_verb_prefix = {" \
		\[ <span style=\"color:[handset.parent.stripe_color]\">[bicon(handset.handset_icon)] [handset.parent.phone_id]</span> \]\
		</b></span> \
		<span class='message'>\
	"}

	message.format_content_prefix = {"\
		, \
	"}

	message.format_content_suffix = {"\
		</span>\
	"}
