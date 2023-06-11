TYPEINFO(/datum/listen_module/input/blobchat)
	id = "blobchat"
/datum/listen_module/input/blobchat
	id = "blobchat"
	channel = SAY_CHANNEL_BLOB

	process(datum/say_message/message)
		. = ..()

	format(datum/say_message/message)
		var/display_name = "[message.speaker]"
		var/mob/mob_speaker = null
		if(istype(message.speaker, /mob))
			mob_speaker = message.speaker
			display_name = mob_speaker.get_heard_name()
		var/rendered = "<span class='game blobsay'>"
		rendered += "<span class='prefix'>BLOB:</span> "
		rendered += "<span class='name text-normal' data-ctx='\ref[mob_speaker?.mind]'>[display_name]</span> "
		rendered += "<span class='message'>[message.say_verb] \"[message.content]\"</span>"
		rendered += "</span>"
		return rendered
