/datum/speech_module/modifier/test_dummy
	id = SPEECH_MODIFIER_TEST_DUMMY
	priority = SPEECH_MODIFIER_PRIORITY_PROCESS_FIRST

/datum/speech_module/modifier/test_dummy/process(datum/say_message/message)
	var/mob/living/carbon/human/tdummy/dummy = message.speaker
	if (!istype(dummy) || dummy.shutup)
		return NO_MESSAGE

	. = message
