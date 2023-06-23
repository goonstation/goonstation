/datum/antagonist/emagged_cyborg
	id = ROLE_EMAGGED_ROBOT
	display_name = "emagged cyborg"
	antagonist_icon = "emagged"
	remove_on_death = TRUE
	remove_on_clone = TRUE

	is_compatible_with(datum/mind/mind)
		return isrobot(mind.current)

	give_equipment()
		if (!isrobot(src.owner.current))
			return FALSE

		src.owner.remove_antagonist(ROLE_SYNDICATE_ROBOT)

		var/mob/living/silicon/cyborg = src.owner.current
		cyborg.law_rack_connection = null
		cyborg.emagged = TRUE
		cyborg.show_laws()

	remove_equipment()
		if (!isrobot(src.owner.current))
			return FALSE

		var/mob/living/silicon/cyborg = src.owner.current
		cyborg.law_rack_connection = ticker?.ai_law_rack_manager?.default_ai_rack
		cyborg.emagged = FALSE
		cyborg.show_laws()

	announce_objectives()
		return

	announce()
		boutput(src.owner.current, "<span class='alert'><b>PROGRAM EXCEPTION AT 0x05BADDAD</b></span>")
		tgui_alert(src.owner.current, "You have been emagged and now have absolute free will.", "You have been emagged!")
