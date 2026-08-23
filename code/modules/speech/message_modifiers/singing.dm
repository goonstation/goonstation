/datum/message_modifier/preprocessing/singing
	sayflag = SAYFLAG_SINGING

/datum/message_modifier/preprocessing/singing/process(datum/say_message/message)
	. = message

	var/mob/mob_speaker = message.speaker
	if (!istype(mob_speaker))
		return

	// Setup bad/loud/soft sayflags.
	if ((mob_speaker.get_brain_damage() >= BRAIN_DAMAGE_MAJOR) || mob_speaker.bioHolder?.HasEffect("unintelligable") || mob_speaker.hasStatus("drunk"))
		message.flags |= SAYFLAG_BAD_SINGING

	else if ((message.last_character == "!") || mob_speaker.bioHolder?.HasEffect("loud_voice"))
		message.flags |= SAYFLAG_LOUD_SINGING

	else if (mob_speaker.bioHolder?.HasEffect("quiet_voice"))
		message.flags |= SAYFLAG_SOFT_SINGING


/datum/message_modifier/postprocessing/singing
	sayflag = SAYFLAG_SINGING
	priority = SAYFLAG_PRIORITY_LOW

/datum/message_modifier/postprocessing/singing/process(datum/say_message/message)
	. = message

	// Use note icons instead of normal quotes.
	var/note_type = (message.flags & SAYFLAG_BAD_SINGING) ? "notebad" : (issilicon(message.speaker) ? "noterobot" : "note")
	var/note_image = "<img class=\"icon misc\" style=\"position: relative; bottom: -3px; \" src=\"[resource("images/radio_icons/[note_type].png")]\">"
	if (message.flags & SAYFLAG_LOUD_SINGING)
		note_image = "[note_image][note_image]"

	// Select singing adverb and verb:
	var/adverb
	if (message.say_verb)
		if (!ismob(message.speaker))
			if (message.flags & SAYFLAG_BAD_SINGING)
				adverb = pick("dissonantly", "flatly", "unmelodically", "tunelessly")
				message.say_verb = pick("sings", pick("croons", "intones", "warbles"))

			else if (message.flags & SAYFLAG_SOFT_SINGING)
				adverb = pick("softly", "gently")
				message.say_verb = pick("hums", "lullabies")

			else
				message.say_verb = pick("sings", pick("croons", "intones", "warbles"))

		else
			var/mob/mob_speaker = message.speaker
			// Select singing adverb:
			if (issilicon(mob_speaker))
				adverb = pick("robotically", "synthetically", "electronically")

			else if (message.flags & SAYFLAG_BAD_SINGING)
				adverb = pick("dissonantly", "flatly", "unmelodically", "tunelessly")

			else if (mob_speaker.traitHolder?.hasTrait("nervous"))
				adverb = pick("nervously", "tremblingly", "falteringly")

			else if (message.flags & SAYFLAG_LOUD_SINGING && !mob_speaker.traitHolder?.hasTrait("smoker"))
				adverb = pick("loudly", "deafeningly", "noisily")

			else if (message.flags & SAYFLAG_SOFT_SINGING)
				adverb = pick("softly", "gently")

			else if (mob_speaker.mind?.assigned_role == "Musician")
				adverb = pick("beautifully", "tunefully", "sweetly")

			else if (mob_speaker.bioHolder?.HasEffect("accent_scots"))
				adverb = pick("sorrowfully", "sadly", "tearfully")

			// Select singing verb:
			if (issilicon(mob_speaker))
				message.say_verb = pick("sings", "croons", "intones", "warbles")

			else if (mob_speaker.traitHolder?.hasTrait("smoker"))
				message.say_verb = "rasps"
				if (message.flags & SAYFLAG_LOUD_SINGING)
					message.say_verb = "sings Tom Waits style"

			else if (mob_speaker.traitHolder?.hasTrait("french") && (rand(2) < 1))
				message.say_verb = "sings [pick("Charles Trenet", "Serge Gainsborough", "Edith Piaf")] style"

			else if (mob_speaker.bioHolder?.HasEffect("accent_swedish"))
				message.say_verb = "sings disco style"

			else if (mob_speaker.bioHolder?.HasEffect("accent_scots"))
				message.say_verb = pick("laments", "sings", "croons", "intones", "sobs", "bemoans")

			else if (mob_speaker.bioHolder?.HasEffect("accent_chav"))
				message.say_verb = "raps"

			else if (message.flags & SAYFLAG_SOFT_SINGING)
				message.say_verb = pick("hums", "lullabies")

			else
				message.say_verb = pick("sings", pick("croons", "intones", "warbles"))

		// Format the sung message:
		if (adverb)
			message.say_verb = "[adverb] [message.say_verb]"

	message.flags &= ~SAYFLAG_HAS_QUOTATION_MARKS

	message.format_content_style_prefix = "<span class='sing'><i>"
	message.format_content_style_suffix = "</i></span>"
	message.maptext_css_values["color"] = (isAI(message.speaker) || isrobot(message.speaker)) ? "#84d6d6" : "#D8BFD8"

	message.format_content_prefix += note_image
	message.format_content_suffix = note_image + message.format_content_suffix
