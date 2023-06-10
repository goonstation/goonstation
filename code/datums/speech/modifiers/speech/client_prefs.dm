//This one isn't great, but there were a bunch of "can I speak" checks and a modifier for each one seemed bad
TYPEINFO(/datum/speech_module/modifier/client_checks)
	id = "client_checks"
/datum/speech_module/modifier/client_checks
	id = "client_checks"

	process(datum/say_message/message)
		. = message
		var/mob/M = message.speaker
		if(!istype(M))
			CRASH("Someone put a client_checks speech mod on a not mob thing. You can't do that!")

		if (M.client && M.client.ismuted())
			boutput(M, "You are currently muted and may not speak.")
			return null

		if(M.client?.preferences?.auto_capitalization)
			message.content = capitalize(message.content)
