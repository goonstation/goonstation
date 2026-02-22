/datum/speech_module/modifier/machinery
	id = SPEECH_MODIFIER_MACHINERY
	priority = SPEECH_MODIFIER_PRIORITY_PROCESS_FIRST

/datum/speech_module/modifier/machinery/process(datum/say_message/message)
	var/obj/machinery/machinery_speaker = message.speaker
	if (!istype(machinery_speaker) || (machinery_speaker.status & NOPOWER))
		return NO_MESSAGE

	. = message
