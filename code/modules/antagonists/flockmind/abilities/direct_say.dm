/datum/targetable/flockmindAbility/directSay
	name = "Narrowbeam Transmission"
	desc = "Directly send a transmission to a target's radio headset, or send a transmission to a radio to broadcast."
	icon_state = "talk"
	cooldown = 0

/datum/targetable/flockmindAbility/directSay/cast(atom/target)
	if(..())
		return TRUE
	if (!src.tutorial_check(FLOCK_ACTION_NARROWBEAM, target))
		return TRUE
	var/obj/item/device/radio/R
	var/message
	if(ismob(target))
		var/mob/mob_target = target
		R = mob_target.find_radio()
		if(R)
			message = html_encode(tgui_input_text(src.holder.owner, "What would you like to broadcast to [target.name]?", "Transmission", theme = "flock"))
			if (!message)
				return TRUE
			logTheThing(LOG_SAY, usr, "Narrowbeam Transmission to [constructTarget(target,"say")]: [message]")
			message = trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			var/flockName = "--.--"
			var/mob/living/intangible/flock/F = holder.owner
			var/datum/flock/flock = F.flock
			if(flock)
				flockName = flock.name
			R.audible_message("<span class='radio' style='color: [R.device_color]'>[SPAN_NAME("Unknown")]<b> [bicon(R)]\[[flockName]\]</b> [SPAN_MESSAGE("crackles, \"[message]\"")]</span>")
			boutput(holder.get_controlling_mob(), SPAN_FLOCKSAY("You transmit to [target.name], \"[message]\""))
		else
			boutput(holder.get_controlling_mob(), SPAN_ALERT("They don't have any compatible radio devices that you can find."))
			return TRUE
	else if(istype(target, /obj/item/device/radio))
		R = target
		message = html_encode(tgui_input_text(src.holder.owner, "What would you like to broadcast to [R]?", "Transmission", theme = "flock"))
		if (!message)
			return TRUE
		logTheThing(LOG_SAY, usr, "Narrowbeam Transmission to [constructTarget(target,"say")]: [message]")
		message = trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		//set up message
		var/datum/language/L = languages.language_cache["english"]
		var/list/messages = L.get_messages(radioGarbleText(message, 10))
		// temporarily swap names about
		var/name = holder.owner.name
		holder.owner.name = "Unknown"
		R.talk_into(holder.owner, messages, 0, "Unknown")
		holder.owner.name = name
	if (!R)
		boutput(holder.get_controlling_mob(), SPAN_ALERT("That isn't a valid target."))
		return TRUE
	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts narrowbeam transmission on radio [constructTarget(R)][ismob(target) ? " worn by [constructTarget(target)]" : ""] with message [message] at [log_loc(src.holder.owner)].")

/datum/targetable/flockmindAbility/directSay/logCast(atom/target)
	return
