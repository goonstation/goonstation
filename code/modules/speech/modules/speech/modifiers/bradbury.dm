/datum/speech_module/modifier/bradbury
	id = SPEECH_MODIFIER_BRADBURY
	priority = SPEECH_MODIFIER_PRIORITY_PROCESS_FIRST

/datum/speech_module/modifier/bradbury/process(datum/say_message/message)
	var/obj/machinery/derelict_aiboss/ai/bradbury = message.speaker
	if (!istype(bradbury) || !bradbury.on)
		return NO_MESSAGE

	. = message
