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
		if(istype(message.speaker, /mob))
			var/mob/mob_speaker = message.speaker
			if (ishuman(mob_speaker) && mob_speaker.name != mob_speaker.real_name)
				if (mob_speaker:wear_id && mob_speaker:wear_id:registered && mob_speaker:wear_id:registered != mob_speaker.real_name)
					alt_name = " (as [mob_speaker:wear_id:registered])"
				else if (!mob_speaker:wear_id)
					alt_name = " (as Unknown)"
			else if (isobserver(mob_speaker))
				name = "Ghost"
				alt_name = " ([mob_speaker.real_name])"
			else if (ispoltergeist(mob_speaker))
				name = "Poltergeist"
				alt_name = " ([mob_speaker.real_name])"
			else if (iswraith(mob_speaker))
				name = "Wraith"
				alt_name = " ([mob_speaker.real_name])"

			mind_ref = "\ref[mob_speaker.mind]"
		else
			name = "[message.speaker.name]"

		return "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name' data-ctx='[mind_ref]'>[name]<span class='text-normal'>[alt_name]</span></span> <span class='message'>[message.say_verb], \"[message.content]\"</span></span>"
