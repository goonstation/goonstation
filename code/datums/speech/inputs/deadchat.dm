TYPEINFO(/datum/listen_module/input/deadchat)
	id = "deadchat"
/datum/listen_module/input/deadchat
	id = "deadchat"
	channel = SAY_CHANNEL_DEAD

	process(datum/say_message/message)
		. = ..()

	format(datum/say_message/message)
		var/alt_name = ""
		var/name = ""
		var/mind_ref = ""
		if (ishuman(message.speaker) && message.face_ident != message.real_ident)
			if (message.card_ident && message.card_ident != message.real_ident)
				alt_name = " (as [message.card_ident])"
			else if (!message.card_ident)
				alt_name = " (as Unknown)"
		else if (isobserver(message.speaker))
			name = "Ghost"
			alt_name = " ([message.real_ident])"
		else if (ispoltergeist(message.speaker))
			name = "Poltergeist"
			alt_name = " ([message.real_ident])"
		else if (iswraith(message.speaker))
			name = "Wraith"
			alt_name = " ([message.real_ident])"
		else
			name = message.real_ident

		if(ismob(message.speaker))
			var/mob/mob_speaker = message.speaker
			mind_ref = "\ref[mob_speaker.mind]"
		return "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name' data-ctx='[mind_ref]'>[name]<span class='text-normal'>[alt_name]</span></span> <span class='message'>[message.say_verb], \"[message.content]\"</span></span>"
