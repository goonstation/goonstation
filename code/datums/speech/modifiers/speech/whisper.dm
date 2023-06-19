TYPEINFO(/datum/speech_module/modifier/whisper)
	id = "whisper"
/datum/speech_module/modifier/whisper
	id = "whisper"

	process(datum/say_message/message)
		. = message
		if (!(message.flags & SAYFLAG_WHISPER))
			return
		message.heard_range = min(1, message.heard_range)
		message.say_verb = "whispers"
		message.content = "<i>[message.content]</i>" //TODO seperate formatting from content
