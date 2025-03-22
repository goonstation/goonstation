/datum/speech_module/modifier/mob_modifiers
	id = SPEECH_MODIFIER_MOB_MODIFIERS
	priority = SPEECH_MODIFIER_PRIORITY_VERY_HIGH

/datum/speech_module/modifier/mob_modifiers/process(datum/say_message/message)
	. = message

	if (!isliving(message.speaker))
		return

	var/mob/living/speaker = message.speaker

	// Prevent speech if the speaker is dead or unconscious.
	if (speaker.stat != STAT_ALIVE)
		qdel(message)
		return null

	// Handle breath modifiers.
	if (iscarbon(speaker))
		var/mob/living/carbon/C = speaker
		if (((C.stamina < STAMINA_WINDED_SPEAK_MIN) && !(message.flags & SAYFLAG_IGNORE_STAMINA)) || ((C.oxyloss > 10) && !HAS_ATOM_PROPERTY(C, PROP_MOB_REBREATHING)) || (C.losebreath >= 4) || C.hasStatus("muted") || (C.reagents?.has_reagent("capulettium_plus") && C.hasStatus("resting")))
			message.flags |= SAYFLAG_WHISPER
			message.whisper_verb = message.speaker.speech_verb_gasp
			message.loudness -= 1

	// Handle stuttering modifiers.
	if (speaker.stuttering && !isrobot(speaker))
		message.say_verb = speaker.speech_verb_stammer
		message.content = stutter(message.content)

	// Handle berserker modifiers.
	var/datum/ailment_data/disease/berserker = speaker.find_ailment_by_type(/datum/ailment/disease/berserker)
	if (berserker && (berserker.stage > 1))
		message.say_verb = "roars"

		if (prob(10))
			message.content = say_furious(message.content)

		message.content = replacetext(message.content, regex(@"[,.?]", "g"), "!")
		message.content = uppertext(message.content)

		for (var/i in 1 to rand(2, 6))
			message.content += "!"

	// Handle drunk modifiers.
	if ((speaker.reagents && (speaker.reagents.get_reagent_amount("ethanol") > 30)) || speaker.traitHolder.hasTrait("alcoholic"))
		message.say_verb = "slurs"

		if ((speaker.reagents.get_reagent_amount("ethanol") > 125) && prob(20))
			message.content = say_superdrunk(message.content)
		else
			message.content = say_drunk(message.content)

	// Handle brain damage modifiers.
	if (speaker.get_brain_damage() >= 60)
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

	// Handle genetic stability modifiers.
	if (speaker.bioHolder && (speaker.bioHolder.genetic_stability < 50) && prob(40))
		message.say_verb = "gurgles"
		message.content = say_gurgle(message.content)

	// Handle low health modifiers.
	if ((speaker.health / max(speaker.max_health, 1)) <= 0.2)
		message.say_verb = speaker.speech_verb_gasp

	// Handle rag muffling.
	if (length(speaker.grabbed_by))
		for (var/obj/item/grab/rag_muffle/RM in speaker.grabbed_by)
			if (!RM.state)
				continue

			message.content = mufflespeech(message.content)
			break

	// Handle Hastur censoring.
	if (global.HasturPresent)
		message.content = replacetext(message.content, regex(@"h[^a-z\d]*a[^a-z\d]*s[^a-z\d]*t[^a-z\d]*u[^a-z\d]*r(?![a-z])", "gi"), "????")

	// Canada day.
#ifdef CANADADAY
	if (prob(30))
		message.content = replacetext(message.content, "?", " Eh?")
#endif
