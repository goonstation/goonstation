TYPEINFO(/datum/speech_module/modifier/singing)
	id = "singing"
/datum/speech_module/modifier/singing
	id = "singing"

	process(datum/say_message/message)
		if (!(message.flags & SAYFLAG_SINGING))
			return message
		// use note icons instead of normal quotes
		var/mob/mob_speaker = istype(message.speaker, /mob) ? message.speaker : null
		var/first_quote = ""
		var/second_quote = ""
		var/note_type = message.flags & SAYFLAG_BAD_SINGING ? "notebad" : "note"
		var/note_img = "<img class=\"icon misc\" style=\"position: relative; bottom: -3px; \" src=\"[resource("images/radio_icons/[note_type].png")]\">"
		if (message.flags & SAYFLAG_LOUD_SINGING)
			first_quote = "[note_img][note_img]"
			second_quote = first_quote
		else
			first_quote = note_img
			second_quote = note_img

		//TODO maybe move these to their appropriate accents?
		// select singing adverb
		var/adverb = ""
		if (message.flags & SAYFLAG_BAD_SINGING)
			adverb = pick("dissonantly", "flatly", "unmelodically", "tunelessly")
		else if (mob_speaker?.traitHolder?.hasTrait("nervous"))
			adverb = pick("nervously", "tremblingly", "falteringly")
		else if (message.flags & SAYFLAG_LOUD_SINGING && !mob_speaker?.traitHolder?.hasTrait("smoker"))
			adverb = pick("loudly", "deafeningly", "noisily")
		else if (message.flags & SAYFLAG_SOFT_SINGING)
			adverb = pick("softly", "gently")
		else if (mob_speaker?.mind?.assigned_role == "Musician")
			adverb = pick("beautifully", "tunefully", "sweetly")
		else if (mob_speaker?.bioHolder?.HasEffect("accent_scots"))
			adverb = pick("sorrowfully", "sadly", "tearfully")
		// select singing verb
		if (mob_speaker?.traitHolder?.hasTrait("smoker"))
			message.say_verb =  "rasps"
			if ((message.flags & SAYFLAG_LOUD_SINGING))
				message.say_verb =  "sings Tom Waits style"
		else if (mob_speaker?.traitHolder?.hasTrait("french") && rand(2) < 1)
			message.say_verb =  "sings [pick("Charles Trenet", "Serge Gainsborough", "Edith Piaf")] style"
		else if (mob_speaker?.bioHolder?.HasEffect("accent_swedish"))
			message.say_verb =  "sings disco style"
		else if (mob_speaker?.bioHolder?.HasEffect("accent_scots"))
			message.say_verb =  pick("laments", "sings", "croons", "intones", "sobs", "bemoans")
		else if (mob_speaker?.bioHolder?.HasEffect("accent_chav"))
			message.say_verb =  "raps"
		else if (message.flags & SAYFLAG_SOFT_SINGING)
			message.say_verb =  pick("hums", "lullabies")
		else
			message.say_verb =  pick("sings", pick("croons", "intones", "warbles"))
		if (adverb != "")
		// combine adverb and verb
			message.say_verb =  "[adverb] [message.say_verb]"
		// add style for singing
		message.content = "[first_quote]<i>[message.content]</i>[second_quote]"
		return message
