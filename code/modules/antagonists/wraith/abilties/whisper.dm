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
		. = ..()
		if (.)
			return .

		if (!ishuman(target))
			boutput(usr, SPAN_ALERT("It would be futile to attempt to force your voice to the consciousness of that."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		var/mob/living/carbon/human/H = target
		if (isdead(H))
			boutput(usr, SPAN_ALERT("They can hear you just fine without the use of your abilities."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		var/message = html_encode(tgui_input_text(usr, "What would you like to whisper to [target]?", "Whisper"))
		if (!message)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		logTheThing(LOG_SAY, usr, "WRAITH WHISPER TO [constructTarget(target,"say")]: [message]")
		message = ghostify_message(trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)))

		var/image/chat_maptext/whisper_text = null
		var/num = hex2num(copytext(md5(src.holder.owner.name), 1, 7))
		var/maptext_color = hsv2rgb((num % 360)%40+240, (num / 360) % 15+5, (((num / 360) / 10) % 15) + 55)
		whisper_text = make_chat_maptext(H, "<span style='text-shadow: 0 0 3px black; -dm-text-outline: 2px black;'>[message]</span>", alpha = 180)
		if(whisper_text)
			whisper_text.show_to(src.holder.owner.client)
			whisper_text.show_to(H.client)
			oscillate_colors(whisper_text, list(maptext_color, "#c482d1"))

		boutput(usr, "<b>You whisper to [target]:</b> [message]")
		boutput(target, "<b>A netherworldly voice whispers into your ears... </b> [message]")
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
		H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
		return CAST_ATTEMPT_SUCCESS


