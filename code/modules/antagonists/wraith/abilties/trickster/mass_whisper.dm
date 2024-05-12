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
		if (..())
			return TRUE
		var/message = input("What would you like to whisper to everyone?", "Whisper", "") as text|null
		message = ghostify_message(copytext(html_encode(message), 1, MAX_MESSAGE_LEN))
		if (message)
			for (var/mob/living/carbon/human/H in range(8, src.holder.owner))
				if (isdead(H))
					continue
				logTheThing(LOG_SAY, holder.owner, "WRAITH WHISPER TO [key_name(H)]: [message]")
				boutput(H, "<b>A netherworldly voice whispers into your ears... </b> \"[message]\"")
				holder.owner.playsound_local(holder.owner.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65)
				H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65)
			boutput(holder.owner, "<b>You whisper to everyone around you:</b> \"[message]\"")
		return TRUE
