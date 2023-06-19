TYPEINFO(/datum/speech_module/modifier/breath)
	id = "breath"
/datum/speech_module/modifier/breath
	id = "breath"
	priority = 100

	process(datum/say_message/message)
		. = message
		if (iscarbon(message.speaker))
			var/mob/living/carbon/H = message.speaker
			// If theres no oxygen
			if (H.oxyloss > 10 || H.losebreath >= 4 || H.hasStatus("muted") || (H.reagents?.has_reagent("capulettium_plus") && H.hasStatus("resting"))) // Perfluorodecalin cap - normal life() depletion - buffer.
				message.flags |= SAYFLAG_WHISPER
