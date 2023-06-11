TYPEINFO(/datum/speech_module/modifier/brain_damage)
	id = "brain_damage"
/datum/speech_module/modifier/brain_damage
	id = "brain_damage"

	process(datum/say_message/message)
		var/mob/speaker = message.speaker
		if(!istype(speaker))
			return message
		else if (speaker.get_brain_damage() >= 60)
			message.content = find_replace_in_string(message.content, "language/modifiers/brain_damage.txt")
			if (prob(50))
				message.prefix = ";" //if you have a headset on, this will cause you to randomly speak into it if you have enough brain damage

			if (prob(20))
				if(prob(25))
					message.content = uppertext(message.content)
					message.content = "[message.content][stutter(pick("!", "!!", "!!!"))]"
				if(!speaker.stuttering && prob(8))
					message.content = stutter(message.content)

			message.say_verb = pick("says","stutters","mumbles","slurs")
		. = message
