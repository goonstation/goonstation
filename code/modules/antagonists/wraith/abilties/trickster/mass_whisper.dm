/datum/targetable/wraithAbility/mass_whisper
	name = "Mass Whisper"
	icon_state = "mass_whisper"
	desc = "Send an ethereal message to all close living beings."
	pointCost = 5
	targeted = FALSE
	cooldown = 10 SECONDS

	// the ghost was inside you all along
	proc/ghostify_message(var/message)
		return message

	cast()
		. = ..()
		var/message = input("What would you like to whisper to everyone?", "Whisper", "") as text|null
		message = ghostify_message(copytext(html_encode(message), 1, MAX_MESSAGE_LEN))
		if (!message)
			return TRUE
		for_by_tcl(H, /mob/living/carbon/human)
			if (!IN_RANGE(holder.owner, H, 8)) continue
			logTheThing(LOG_SAY, holder.owner, "WRAITH WHISPER TO [key_name(H)]: [message]")
			boutput(H, "<span class='hint'><b>A netherworldly voice whispers into your ears... </b> [message]</span>")
			src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
			H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)

		boutput(holder.owner, "<span class='success'><b>You whisper to everyone around you:</b> [message]</span>")
