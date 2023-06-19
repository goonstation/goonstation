TYPEINFO(/datum/listen_module/input/hivechat)
	id = "hivechat"
/datum/listen_module/input/hivechat
	id = "hivechat"
	channel = SAY_CHANNEL_HIVEMIND

	process(datum/say_message/message)
		. = ..()

	format(datum/say_message/message)
		var/mob/mob_speaker = null
		if(istype(message.speaker, /mob))
			mob_speaker = message.speaker
		var/rendered = "<span class='game hivesay'>"
		rendered += "<span class='prefix'>HIVEMIND:</span> "
		rendered += "<span class='name text-normal' data-ctx='\ref[mob_speaker?.mind]'>[message.real_ident]</span> "
		rendered += "<span class='message'>[message.say_verb] \"[message.content]\"</span>"
		rendered += "</span>"
		return rendered
