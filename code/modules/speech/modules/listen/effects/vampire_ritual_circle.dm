/datum/listen_module/effect/vampire_ritual_circle
	id = LISTEN_EFFECT_VAMPIRE_RITUAL_CIRCLE

/datum/listen_module/effect/vampire_ritual_circle/process(datum/say_message/message)
	var/mob/M = message.speaker
	if (!istype(M) || !(M.mind?.get_antagonist(ROLE_COVEN_VAMPIRE) || isadmin(M)))
		return

	var/obj/decal/cleanable/vampire_ritual_circle/ritual_circle = src.parent_tree.listener_parent
	if (!istype(ritual_circle))
		return

	if (ritual_circle.current_ritual)
		var/datum/vampire_ritual/ritual = ritual_circle.current_ritual

		// If the ritual is finished but its effects are still ongoing, don't accept any further incantations.
		if (ritual.ritual_completed)
			return

		// If the "stop" incantation is found, cancel the current ritual.
		if (findtext(message.original_content, global.VampireRitualManager.stop_ritual_incantation))
			if (global.VampireRitualManager.StopRitual(ritual))
				SEND_SIGNAL(message.signal_recipient, COMSIG_APPLY_CALLBACK_TO_MESSAGE_COPIES, CALLBACK(src, PROC_REF(maptext_effect)))

			return

		// Otherwise, attempt to locate the next incantation line in the message content.
		if (findtext(message.original_content, ritual.incantation_lines[ritual.ritual_stage + 1]))
			if (global.VampireRitualManager.ProgressRitual(ritual, message.speaker))
				SEND_SIGNAL(message.signal_recipient, COMSIG_APPLY_CALLBACK_TO_MESSAGE_COPIES, CALLBACK(src, PROC_REF(maptext_effect)))

			return


	// If there is no active ritual, attempt to locate the first line of an incantation in the message content.
	else
		for (var/line as anything in global.VampireRitualManager.incantation_first_lines)
			if (!findtext(message.original_content, line))
				continue

			var/ritual_type = global.VampireRitualManager.incantation_first_lines[line]
			if (global.VampireRitualManager.StartRitual(ritual_type, ritual_circle, message.speaker))
				SEND_SIGNAL(message.signal_recipient, COMSIG_APPLY_CALLBACK_TO_MESSAGE_COPIES, CALLBACK(src, PROC_REF(maptext_effect)))

			return

/datum/listen_module/effect/vampire_ritual_circle/proc/maptext_effect(datum/say_message/message)
	message.maptext_css_values["color"] = "#ff0000"
