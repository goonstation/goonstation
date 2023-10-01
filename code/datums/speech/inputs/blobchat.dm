TYPEINFO(/datum/listen_module/input/blobchat)
	id = "blobchat"
/datum/listen_module/input/blobchat
	id = "blobchat"
	channel = SAY_CHANNEL_BLOB

	process(datum/say_message/message)
		. = ..()

	format(datum/say_message/message)
		var/mob/mob_speaker = null
		if(istype(message.speaker, /mob))
			mob_speaker = message.speaker
		var/rendered = "<span class='game blobsay'>"
		rendered += "<span class='prefix'>BLOB:</span> "
		rendered += "<span class='name text-normal' data-ctx='\ref[mob_speaker?.mind]'>[message.real_ident]</span> "
		rendered += "<span class='message'>[message.say_verb] \"[message.content]\"</span>"
		rendered += "</span>"
		return rendered
