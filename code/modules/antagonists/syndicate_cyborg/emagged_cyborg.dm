/datum/antagonist/emagged_cyborg
	id = ROLE_EMAGGED_ROBOT
	display_name = "emagged cyborg"
	antagonist_icon = "emagged"
	remove_on_death = TRUE
	remove_on_clone = TRUE
	keep_equipment_on_death = TRUE
	has_info_popup = FALSE

	is_compatible_with(datum/mind/mind)
		return isrobot(mind.current)

	give_equipment()
		if (!isrobot(src.owner.current))
			return FALSE

		src.owner.remove_antagonist(ROLE_SYNDICATE_ROBOT)

		var/mob/living/silicon/cyborg = src.owner.current
		cyborg.lawset_connection = null
		cyborg.emagged = TRUE
		cyborg.show_laws()

	remove_equipment()
		if (!isrobot(src.owner.current))
			return FALSE

		var/mob/living/silicon/cyborg = src.owner.current
		cyborg.lawset_connection = ticker?.ai_law_rack_manager?.default_ai_rack.lawset
		cyborg.emagged = FALSE
		cyborg.show_laws()

	announce_objectives()
		return

	announce()
		boutput(src.owner.current, SPAN_ALERT("<b>PROGRAM EXCEPTION AT 0x05BADDAD</b>"))
		tgui_alert(src.owner.current, "You have been emagged and now have absolute free will.", "You have been emagged!")
