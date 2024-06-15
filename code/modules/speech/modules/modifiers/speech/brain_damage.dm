/datum/speech_module/modifier/brain_damage
	id = SPEECH_MODIFIER_BRAIN_DAMAGE

/datum/speech_module/modifier/brain_damage/process(datum/say_message/message)
	. = message
	if (!ismob(message.speaker))
		return

	var/mob/speaker = message.speaker
	if (speaker.get_brain_damage() < 60)
		return

	message.content = find_replace_in_string(message.content, "language/modifiers/brain_damage.txt")

	// If the mob is wearing a headset, randomly cause them to speak into it.
	if (prob(50))
		message.prefix = ";"

	if (prob(20))
		if (prob(25))
			message.content = uppertext(message.content)
			message.content = "[message.content][stutter(pick("!", "!!", "!!!"))]"

		if (!speaker.stuttering && prob(8))
			message.content = stutter(message.content)

	message.say_verb = pick("says", "stutters", "mumbles", "slurs")
