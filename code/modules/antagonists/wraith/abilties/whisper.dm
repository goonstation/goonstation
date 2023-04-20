/datum/targetable/wraithAbility/whisper
	name = "Whisper"
	icon_state = "whisper"
	desc = "Send an ethereal message to a living being."
	targeted = TRUE
	target_anything = FALSE
	pointCost = 1
	cooldown = 2 SECONDS
	min_req_dist = 20
	proc/ghostify_message(var/message)
		return message

	cast(atom/target)
		. = ..()
		var/mob/M = target
		if (isdead(M))
			boutput(src.holder.owner, "<span class='alert'>They can hear you just fine without the use of your abilities.</span>")
			return TRUE
		else
			var/message = html_encode(tgui_input_text(src.holder.owner, "What would you like to whisper to [M]?", "Whisper"))
			logTheThing(LOG_SAY, src.holder.owner, "WRAITH WHISPER TO [constructTarget(M,"say")]: [message]")
			message = ghostify_message(trim(copytext(sanitize(message), 1, 255)))
			if (!message)
				return TRUE
			boutput(src.holder.owner, "<b>You whisper to [M]:</b> [message]")
			boutput(target, "<b>A netherworldly voice whispers into your ears... </b> [message]")
			src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
			M.playsound_local(M.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
