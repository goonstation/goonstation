/datum/targetable/wraithAbility/mass_whisper
	name = "Mass Whisper"
	icon_state = "mass_whisper"
	desc = "Send an ethereal message to all close living beings."
	pointCost = 5
	targeted = FALSE
	cooldown = 10 SECONDS

	proc/ghostify_message(var/message)
		return message

	cast()
		..()
		var/message = tgui_input_text(src.holder.owner, "What would you like to whisper to everyone?", name)
		if (!message)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		message = ghostify_message(copytext(html_encode(message), 1, MAX_MESSAGE_LEN))

		var/image/chat_maptext/whisper_text = null
		var/maptext_color = dead_maptext_color(src.holder.owner.name)

		var/hearers = 0
		for (var/mob/living/carbon/human/H in range(8, src.holder.owner))
			if (isdead(H))
				continue
			logTheThing(LOG_SAY, holder.owner, "WRAITH WHISPER TO [key_name(H)]: [message]")
			whisper_text = make_chat_maptext(H, "<span style='text-shadow: 0 0 3px black; -dm-text-outline: 2px black;'>[message]</span>", alpha = 180)
			if(whisper_text)
				whisper_text.show_to(src.holder.owner.client)
				whisper_text.show_to(H.client)
				oscillate_colors(whisper_text, list(maptext_color, "#c482d1"))
			boutput(H, "<b>A netherworldly voice whispers into your ears... </b> \"[message]\"")
			H.playsound_local(H, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65)
			hearers++
		if (hearers == 0)
			boutput(holder.owner, SPAN_ALERT("Nobody is around to hear your whispers..."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		else
			boutput(holder.owner, "<b>You whisper to [get_english_num(hearers)] being[s_es(hearers)] around you:</b> \"[message]\"")
			holder.owner.playsound_local(holder.owner, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65)
		return CAST_ATTEMPT_SUCCESS
