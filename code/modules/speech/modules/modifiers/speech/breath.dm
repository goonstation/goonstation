/datum/speech_module/modifier/breath
	id = SPEECH_MODIFIER_BREATH
	priority = 100

/datum/speech_module/modifier/breath/process(datum/say_message/message)
	. = message
	if (!iscarbon(message.speaker))
		return

	var/mob/living/carbon/H = message.speaker
	if (((H.stamina < STAMINA_WINDED_SPEAK_MIN) && (message.flags & SAYFLAG_IGNORE_STAMINA)) || (H.oxyloss > 10) || (H.losebreath >= 4) || H.hasStatus("muted") || (H.reagents?.has_reagent("capulettium_plus") && H.hasStatus("resting")))
		message.flags |= SAYFLAG_WHISPER
		message.whisper_verb = message.speaker.speech_verb_gasp
		message.loudness -= 1
