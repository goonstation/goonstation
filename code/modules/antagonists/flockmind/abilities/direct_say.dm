/datum/targetable/flockmindAbility/directSay
	name = "Narrowbeam Transmission"
	desc = "Directly send a transmission to a target's radio headset, or send a transmission to a radio to broadcast."
	icon_state = "talk"
	cooldown = 0

/datum/targetable/flockmindAbility/directSay/cast(atom/target)
	if(..() || !src.tutorial_check(FLOCK_ACTION_NARROWBEAM, target))
		return TRUE

	var/message
	var/obj/item/device/radio/radio

	if (istype(target, /obj/item/device/radio))
		radio = target

		message = html_encode(tgui_input_text(src.holder.owner, "What would you like to broadcast to [radio]?", "Transmission", theme = "flock"))
		if (!message)
			return TRUE

		message = global.radioGarbleText(message, 10)

		var/message_params = list(
			"output_module_channel" = SAY_CHANNEL_EQUIPPED,
			"speaker_to_display" = "Unknown",
			"voice_ident" = "Unknown",
		)

		src.holder.owner.say(message, flags = SAYFLAG_SPOKEN_BY_PLAYER, message_params = message_params, atom_listeners_override = list(radio))

	else if (ismob(target))
		var/mob/mob_target = target
		radio = mob_target.find_radio()
		if (!radio)
			boutput(holder.get_controlling_mob(), SPAN_ALERT("They don't have any compatible radio devices that you can find."))
			return TRUE

		message = html_encode(tgui_input_text(src.holder.owner, "What would you like to broadcast to [radio]?", "Transmission", theme = "flock"))
		if (!message)
			return TRUE

		var/message_params = list(
			"output_module_channel" = SAY_CHANNEL_OUTLOUD,
			"speaker" = radio,
			"language" = global.SpeechManager.GetLanguageInstance(LANGUAGE_ENGLISH),
		)

		src.holder.owner.say(message, flags = SAYFLAG_IGNORE_POSITION | SAYFLAG_SPOKEN_BY_PLAYER, message_params = message_params, atom_listeners_override = list(src.holder.owner, mob_target))

	else
		boutput(holder.get_controlling_mob(), SPAN_ALERT("That isn't a valid target."))
		return TRUE

	logTheThing(LOG_SAY, usr, "Narrowbeam Transmission to [constructTarget(target, "say")]: [message]")
	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts narrowbeam transmission on radio [constructTarget(radio)][ismob(target) ? " worn by [constructTarget(target)]" : ""] with message [message] at [log_loc(src.holder.owner)].")

/datum/targetable/flockmindAbility/directSay/logCast(atom/target)
	return
