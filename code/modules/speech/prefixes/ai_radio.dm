ABSTRACT_TYPE(/datum/say_prefix/ai_radio)
/datum/say_prefix/ai_radio/is_compatible_with(datum/say_message/message, datum/speech_module_tree/say_tree)
	. = FALSE

	if (isAI(message.speaker))
		return TRUE

/datum/say_prefix/ai_radio/process(datum/say_message/message, datum/speech_module_tree/say_tree)
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

	message.prefix = replacetext(message.prefix, src.id, ":")
	message.say_sound = 'sound/misc/talk/radio.ogg'
	message.atom_listeners_to_be_excluded ||= list()
	message.atom_listeners_to_be_excluded[radio] = TRUE

	var/datum/say_message/radio_message = message.Copy()
	radio_message.atom_listeners_override = list(radio)
	say_tree.GetOutputByID(SPEECH_OUTPUT_EQUIPPED)?.process(radio_message)

/datum/say_prefix/ai_radio/proc/get_radio(mob/living/silicon/ai/AI)
	return


/datum/say_prefix/ai_radio/one
	id = ":1"

/datum/say_prefix/ai_radio/one/get_radio(mob/living/silicon/ai/AI)
	return AI.radio1


/datum/say_prefix/ai_radio/two
	id = ":2"

/datum/say_prefix/ai_radio/two/get_radio(mob/living/silicon/ai/AI)
	return AI.radio2


/datum/say_prefix/ai_radio/three
	id = ":3"

/datum/say_prefix/ai_radio/three/get_radio(mob/living/silicon/ai/AI)
	return AI.radio3
