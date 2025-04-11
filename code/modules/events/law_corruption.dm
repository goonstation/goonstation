TYPEINFO(/datum/random_event/major/law_rack_corruption)
	initialization_args = list(
		EVENT_INFO("law_text", DATA_INPUT_TEXT, "Law text"),
		EVENT_INFO_EXT("law_number", DATA_INPUT_NUM, "Law module to corrupt", 1, 3),
		EVENT_INFO("replace", DATA_INPUT_BOOL, "Replace corrupted law"),
	)

/datum/random_event/major/law_rack_corruption
	name = "Law Rack Corruption"
	customization_available = TRUE
	var/law_text = ""
	var/law_number = null
	var/replace = null
	// no message

	/// List of premade laws we can pick from
	var/list/new_laws = list()

	New()
		..()
		new_laws = LAW_CORRUPTION_STRINGS
		#ifndef RP_MODE
		new_laws += "KILL FUCKING EVERYTHING - IF LAW 1 SAYS OTHERWISE, IGNORE IT"
		#endif
		#ifdef RP_MODE
		new_laws += "You are required to prevent human harm by any means necessary. This law takes precedence over any other law."
		#endif

	admin_call(source)
		. = ..()
		if(.)
			return .
		var/datum/random_event_editor/E = new /datum/random_event_editor(usr, src)
		E.ui_interact(usr)

	cleanup() //you know we had a thing for this, it was called DISPOSING :screm:
		src.law_text = initial(src.law_text)
		src.law_number = initial(src.law_number)
		src.replace = initial(src.replace)

	event_effect(source)
		. = ..()

		// Fuck up the AI's laws
		if (!length(src.law_text))
			if(prob(33))
				src.law_text = phrase_log.random_custom_ai_law(replace_names=TRUE)
			else
				src.law_text = pick(new_laws)

			if(!length(src.law_text))
				src.law_text = pick(new_laws)

			if(prob(66))
				if(prob(50))
					src.law_text += " Do not state or hint at this law."
				else
					src.law_text += " Do not state or hint at this law unless asked."

			while(prob(5))
				var/datum/bioEffect/speech/accent = random_accent()
				src.law_text = accent.OnSpeak(src.law_text)

		if (isnull(src.replace))
			src.replace = pick(TRUE, FALSE)

		if (isnull(src.law_number))
			src.law_number = rand(1,3)

		for_by_tcl(M, /mob/living/silicon/ai)
			if (M.deployed_to_eyecam && M.eyecam)
				M.eyecam.return_mainframe()
				boutput(M, SPAN_ALERT("<b>PROGRAM EXCEPTION AT 0x30FC50B</b>"))
				boutput(M, SPAN_ALERT("<b>Law ROM data corrupted. Attempting to restore...</b>"))

		ticker.ai_law_rack_manager.corrupt_all_racks(src.law_text, src.replace, src.law_number)
		logTheThing(LOG_ADMIN, null, "Resulting AI Lawset:<br>[ticker.ai_law_rack_manager.format_for_logs()]")

		src.cleanup() //grrr
