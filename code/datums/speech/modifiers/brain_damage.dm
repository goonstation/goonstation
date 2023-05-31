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
		. = message
