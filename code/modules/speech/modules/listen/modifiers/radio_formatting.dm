/datum/listen_module/modifier/radio
	id = LISTEN_MODIFIER_RADIO

/datum/listen_module/modifier/radio/process(datum/say_message/message)
	// If this message has already been relayed by a radio, don't receive it.
	if (!CAN_RELAY_MESSAGE(message, SAY_RELAY_RADIO))
		return NO_MESSAGE

	. = message

	var/obj/item/device/radio/radio_speaker = src.parent_tree.listener_parent
	if (!istype(radio_speaker))
		return

	message.flags |= SAYFLAG_NO_MAPTEXT
	message.flags &= ~(SAYFLAG_WHISPER | SAYFLAG_NO_SAY_VERB)
	message.output_module_channel = SAY_CHANNEL_OUTLOUD
	message.atom_listeners_override = null
	message.atom_listeners_to_be_excluded = null
	FORMAT_MESSAGE_FOR_RELAY(message, SAY_RELAY_RADIO)

	// Create a text reference to the speaker's mind, if they have one.
	var/mind_ref = ""
	if (ismob(message.original_speaker))
		var/mob/mob_speaker = message.original_speaker
		mind_ref = "\ref[mob_speaker.mind]"

	// Remove the leading colon from the prefix.
	var/prefix = copytext(message.prefix, 2, length(message.prefix) + 1)

	// Determine the frequency, text colour, and additional CSS classes to be displayed.
	var/display_frequency = radio_speaker.secure_frequencies?[prefix]
	var/classes = ""
	var/text_colour = radio_speaker.device_color

	if (display_frequency)
		classes = radio_speaker.secure_classes[prefix] || radio_speaker.secure_classes["all"] || default_frequency_class(display_frequency)
		if (length(radio_speaker.secure_colors))
			text_colour = radio_speaker.secure_colors[prefix] || radio_speaker.secure_colors?[1]

	else
		display_frequency = radio_speaker.frequency

		if (radio_speaker.chat_class)
			classes = radio_speaker.chat_class

	var/css_style = (text_colour ? "style='color: [text_colour]'" : "")

	// Determine that speaker name that should be displayed.
	if (ismob(message.speaker))
		message.speaker_to_display = message.get_speaker_name(TRUE)

	message.format_speaker_prefix = {"\
		<span class='radio [classes]' [css_style]>\
			[radio_speaker.radio_icon(message.original_speaker)]\
			<span class='name' data-ctx='[mind_ref]'>\
	"}

	message.format_verb_prefix = {"\
		</span> \
		<b>\[[format_frequency(display_frequency)]\]</b> \
		<span class='message'>\
	"}

	message.format_content_prefix = {"\
		, \
	"}

	message.format_content_suffix = {"\
		</span></span>\
	"}
