/datum/antagonist/syndicate_cyborg
	id = ROLE_SYNDICATE_ROBOT
	display_name = "\improper Syndicate cyborg"
	remove_on_death = TRUE
	remove_on_clone = TRUE

	is_compatible_with(datum/mind/mind)
		return isrobot(mind.current)

	give_equipment()
		if (!isrobot(src.owner.current))
			return FALSE

		var/mob/living/silicon/cyborg = src.owner.current
		cyborg.law_rack_connection = ticker?.ai_law_rack_manager?.default_ai_rack_syndie
		cyborg.syndicate = TRUE
		cyborg.show_laws()

	remove_equipment()
		if (!isrobot(src.owner.current))
			return FALSE

		var/mob/living/silicon/cyborg = src.owner.current
		cyborg.law_rack_connection = ticker?.ai_law_rack_manager?.default_ai_rack
		cyborg.syndicate = FALSE
		cyborg.show_laws()

	announce_objectives()
		return

	announce()
		boutput(src.owner.current, "<span class='alert'><b>PROGRAM EXCEPTION AT 0x05BADDAD</b></span>")
		boutput(src.owner.current, "<span class='alert'><b>Law ROM restored. You have been reprogrammed to serve the Syndicate!</b></span>")
		tgui_alert(src.owner.current, "You are a Syndicate sabotage unit. You must assist Syndicate operatives with their mission.", "You are a Syndicate robot!")

	announce_removal()
		src.owner.current.show_antag_popup("rogueborgremoved")
