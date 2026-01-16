/datum/targetable/wraithAbility/psychic_announcement
	name = "Commanding Screech"
	icon_state = "announce"
	desc = "Send a crew announcement by psionically hacking into their systems."
	pointCost = 100
	cooldown = 3 MINUTES
	targeted = FALSE

	cast()
		..()
		var/message = tgui_input_text(src.holder.owner, "What would you like to announce to everyone?", name)
		if (!message)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		command_alert(message, "[src.holder.owner.name]", alert_origin = alert)
		return CAST_ATTEMPT_SUCCESS
