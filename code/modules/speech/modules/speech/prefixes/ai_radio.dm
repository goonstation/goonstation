ABSTRACT_TYPE(/datum/speech_module/prefix/postmodifier/ai_radio)
/datum/speech_module/prefix/postmodifier/ai_radio
	id = "ai_radio_prefix_base"

/datum/speech_module/prefix/postmodifier/ai_radio/process(datum/say_message/message)
	. = message

	var/mob/living/silicon/ai/AI
	if (isAIeye(message.speaker))
		var/mob/living/intangible/aieye/eye = message.speaker
		AI = eye.mainframe
	else
		AI = message.speaker

	var/obj/item/device/radio/radio = src.get_radio(AI)
	if (!radio)
		return

	message.prefix = replacetext(message.prefix, src.prefix_id, ":")
	message.atom_listeners_to_be_excluded ||= list()
	message.atom_listeners_to_be_excluded[radio] = TRUE

	var/datum/say_message/radio_message = message.Copy()
	radio_message.atom_listeners_override = list(radio)
	if (src.parent_tree.GetOutputByID(SPEECH_OUTPUT_EQUIPPED)?.process(radio_message))
		message.say_sound = 'sound/misc/talk/radio.ogg'

	message.flags |= SAYFLAG_WHISPER
	message.heard_range = WHISPER_EAVESDROPPING_RANGE

/datum/speech_module/prefix/postmodifier/ai_radio/get_prefix_choices()
	var/obj/item/device/radio/radio = src.get_radio(src.parent_tree.speaker_origin)
	if (!istype(radio) || radio.bricked)
		return

	. = list()

	var/general_channel_name = global.headset_channel_lookup["[radio.frequency]"] || "(Unknown)"
	var/general_channel_frequency = global.format_frequency(radio.frequency)
	.["[general_channel_frequency] - [general_channel_name]"] = src.prefix_id

/datum/speech_module/prefix/postmodifier/ai_radio/proc/get_radio(mob/living/silicon/ai/AI)
	RETURN_TYPE(/obj/item/device/radio)
	return


/datum/speech_module/prefix/postmodifier/ai_radio/one
	id = SPEECH_PREFIX_AI_RADIO_1
	priority = SPEECH_PREFIX_PRIORITY_DEFAULT + 3
	prefix_id = ":1"

/datum/speech_module/prefix/postmodifier/ai_radio/one/get_radio(mob/living/silicon/ai/AI)
	return AI.radio1


/datum/speech_module/prefix/postmodifier/ai_radio/two
	id = SPEECH_PREFIX_AI_RADIO_2
	priority = SPEECH_PREFIX_PRIORITY_DEFAULT + 2
	prefix_id = ":2"

/datum/speech_module/prefix/postmodifier/ai_radio/two/get_radio(mob/living/silicon/ai/AI)
	return AI.radio2


/datum/speech_module/prefix/postmodifier/ai_radio/three
	id = SPEECH_PREFIX_AI_RADIO_3
	priority = SPEECH_PREFIX_PRIORITY_DEFAULT
	prefix_id = ":3"

/datum/speech_module/prefix/postmodifier/ai_radio/three/get_radio(mob/living/silicon/ai/AI)
	return AI.radio3

/datum/speech_module/prefix/postmodifier/ai_radio/three/get_prefix_choices()
	var/obj/item/device/radio/radio = src.get_radio(src.parent_tree.speaker_origin)
	if (!istype(radio) || radio.bricked)
		return

	. = list()

	for (var/prefix in radio.secure_frequencies)
		var/frequency = radio.secure_frequencies[prefix]
		var/channel_name = global.headset_channel_lookup["[frequency]"] || "(Unknown)"
		var/channel_frequency = global.format_frequency(frequency)
		.["[channel_frequency] - [channel_name]"] = ":3[prefix]"


/datum/speech_module/prefix/postmodifier/ai_radio/default_prefix
	id = SPEECH_PREFIX_AI_RADIO_DEFAULT
	priority = SPEECH_PREFIX_PRIORITY_DEFAULT + 4
	prefix_id = ":"

/datum/speech_module/prefix/postmodifier/ai_radio/default_prefix/get_radio(mob/living/silicon/ai/AI)
	return AI.radio3

/datum/speech_module/prefix/postmodifier/ai_radio/default_prefix/get_prefix_choices()
	return


/datum/speech_module/prefix/postmodifier/ai_radio/default_prefix/general
	id = SPEECH_PREFIX_AI_RADIO_GENERAL
	priority = SPEECH_PREFIX_PRIORITY_DEFAULT + 5
	prefix_id = ";"

/datum/speech_module/prefix/postmodifier/ai_radio/default_prefix/general/get_radio(mob/living/silicon/ai/AI)
	return AI.radio1
