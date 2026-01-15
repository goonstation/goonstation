/datum/targetable/wraithAbility/psychic_announcement
	name = "Commanding Screech"
	icon_state = "announce"
	desc = "Send a crew announcement by psionically hacking into their systems."
	pointCost = 100
	cooldown = 3 MINUTES
	targeted = FALSE

	cast()
		..()
		var/message = tgui_input_text(src.holder.owner, "What would you like to whisper to everyone?", name)
		if (!message)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		var/alert = ALERT_WRAITH
		if (istype(src.holder.owner, /mob/living/intangible/wraith/wraith_harbinger))
			alert = ALERT_HARBINGER
		else if (istype(src.holder.owner, /mob/living/intangible/wraith/wraith_decay))
			alert = ALERT_PLAGUEBRINGER
		else if (istype(src.holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			alert = ALERT_TRICKSTER


		command_alert(message, "[src.holder.owner.name]", alert_origin = alert)
		return CAST_ATTEMPT_SUCCESS
