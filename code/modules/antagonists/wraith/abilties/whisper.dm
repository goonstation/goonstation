/datum/targetable/wraithAbility/whisper
	name = "Whisper"
	icon_state = "whisper"
	desc = "Send an ethereal message to a living being."
	targeted = 1
	target_anything = 1
	pointCost = 1
	cooldown = 2 SECONDS
	min_req_dist = 20
	proc/ghostify_message(var/message)
		return message

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (isdead(H))
				boutput(usr, SPAN_ALERT("They can hear you just fine without the use of your abilities."))
				return 1
			else
				var/message = html_encode(tgui_input_text(usr, "What would you like to whisper to [target]?", "Whisper"))
				logTheThing(LOG_SAY, usr, "WRAITH WHISPER TO [constructTarget(target,"say")]: [message]")
				message = ghostify_message(trimtext(copytext(sanitize(message), 1, 255)))
				if (!message)
					return 1
				boutput(usr, "<b>You whisper to [target]:</b> [message]")
				boutput(target, "<b>A netherworldly voice whispers into your ears... </b> [message]")
				usr.playsound_local(usr.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
				H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
		else
			boutput(usr, SPAN_ALERT("It would be futile to attempt to force your voice to the consciousness of that."))
			return 1
