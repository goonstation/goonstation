/datum/speech_module/modifier/mob_modifiers
	id = SPEECH_MODIFIER_MOB_MODIFIERS
	priority = SPEECH_MODIFIER_PRIORITY_VERY_HIGH
	var/static/regex/berserker_regex = regex(@"[,.?]", "g")
	var/static/regex/hastur_regex = regex(@"h+[^a-z\d]*a+[^a-z\d]*s+[^a-z\d]*t+[^a-z\d]*u+[^a-z\d]*r+(?![a-z])", "gi")

/datum/speech_module/modifier/mob_modifiers/process(datum/say_message/message)
	. = message

	if (!isliving(message.speaker))
		return

	var/mob/living/speaker = message.speaker

	// Prevent speech if the speaker is dead or unconscious.
	if (speaker.stat != STAT_ALIVE)
		return NO_MESSAGE

	if (!speaker.mind)
		message.flags |= SAYFLAG_DELIMITED_CHANNEL_ONLY

	// Handle breath modifiers.
	if (iscarbon(speaker))
		var/mob/living/carbon/C = speaker
		if (((C.stamina < STAMINA_WINDED_SPEAK_MIN) && !(message.flags & SAYFLAG_IGNORE_STAMINA)) || ((C.oxyloss > 10) && !HAS_ATOM_PROPERTY(C, PROP_MOB_REBREATHING)) || (C.losebreath >= 4) || C.hasStatus("muted") || (C.reagents?.has_reagent("capulettium_plus") && C.hasStatus("resting")))
			message.flags |= SAYFLAG_WHISPER | SAYFLAG_DO_NOT_PASS_TO_EQUIPPED_MODULES
			message.whisper_verb = message.speaker.speech_verb_gasp
			message.loudness -= 1

	// Handle stuttering modifiers.
	if (speaker.stuttering && !isrobot(speaker))
		message.say_verb = speaker.speech_verb_stammer
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(stutter)))

	// Handle berserker modifiers.
	var/datum/ailment_data/disease/berserker = speaker.find_ailment_by_type(/datum/ailment/disease/berserker)
	if (berserker && (berserker.stage > 1))
		message.say_verb = "roars"

		if (prob(10))
			APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(say_furious)))

		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(src.berserker_regex, TYPE_PROC_REF(/regex, Replace), "!"))
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(uppertext_wrapper)))

		for (var/i in 1 to rand(2, 6))
			message.content += MAKE_CONTENT_MUTABLE("!")

	// Handle drunk modifiers.
	if ((speaker.reagents && (speaker.reagents.get_reagent_amount("ethanol") > 30)) || speaker.traitHolder.hasTrait("alcoholic"))
		message.say_verb = "slurs"

		if ((speaker.reagents.get_reagent_amount("ethanol") > 125) && prob(20))
			APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(say_superdrunk)))
		else
			APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(say_drunk)))

	// Handle brain damage modifiers.
	if (speaker.get_brain_damage() >= BRAIN_DAMAGE_MAJOR)
		message.say_verb = pick("says", "stutters", "mumbles", "slurs")
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(find_replace_in_string), "language/modifiers/brain_damage.txt"))

	if (speaker.get_brain_damage() >= BRAIN_DAMAGE_SEVERE)
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(src, PROC_REF(brain_damage_text), 50))

	else if (speaker.get_brain_damage() >= BRAIN_DAMAGE_MINOR)
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(src, PROC_REF(brain_damage_text), 5))

		if (speaker.get_brain_damage() >= BRAIN_DAMAGE_MODERATE)
			if (prob(5))
				APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(uppertext_wrapper)))
				message.content += MAKE_CONTENT_MUTABLE(stutter(pick("!", "!!", "!!!")))

			if (!speaker.stuttering && prob(2))
				APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(stutter)))

	// Handle genetic stability modifiers.
	if (speaker.bioHolder && (speaker.bioHolder.genetic_stability < 50) && prob(40))
		message.say_verb = "gurgles"
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(say_gurgle)))

	// Handle low health modifiers.
	if ((speaker.health / max(speaker.max_health, 1)) <= 0.2)
		message.say_verb = speaker.speech_verb_gasp

	// Handle rag muffling.
	if (length(speaker.grabbed_by))
		for (var/obj/item/grab/rag_muffle/RM in speaker.grabbed_by)
			if (!RM.state)
				continue

			APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(mufflespeech)))
			break

	// Handle Hastur censoring.
	if (global.HasturPresent)
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(src.hastur_regex, TYPE_PROC_REF(/regex, Replace), "????"))

	// Canada day.
#ifdef CANADADAY
	if (prob(30))
		APPLY_CALLBACK_TO_MESSAGE_CONTENT(message, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(replacetext_wrapper), "?", " Eh?"))
#endif

/datum/speech_module/modifier/mob_modifiers/proc/brain_damage_text(string, probability)
	. = ""

	for (var/i in 1 to length(string))
		if (prob(probability))
			if (is_uppercase_letter(string[i]))
				. += pick(global.uppercase_letters)
			else if (is_lowercase_letter(string[i]))
				. += pick(global.lowercase_letters)
			else
				. += string[i]
		else
			. += string[i]
			if (prob(5))
				. += string[i]
