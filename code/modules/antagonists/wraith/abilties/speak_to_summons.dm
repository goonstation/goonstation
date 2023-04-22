/datum/targetable/wraithAbility/speak
	name = "Spirit message"
	desc = "Telepathically speak to your minions."
	icon_state = "speak_summons"
	targeted = FALSE

	cast(mob/target)
		. = ..()
		var/mob/living/intangible/wraith/W = src.holder.owner

		var/message = html_encode(input("What would you like to whisper to your minions?", "Whisper", "") as text)

		if (!length(W.summons))
			boutput(W, !prob(1) ? "<span class='alert'>You have no minions to talk to.</span>" : "<span class='alert'>No minions?</span>")
			return TRUE
		for(var/mob/living/critter/C in W.summons)
			logTheThing(LOG_SAY, W, "WRAITH WHISPER TO [constructTarget(C,"say")]: [message]")
			message = trim(copytext(sanitize(message), 1, 255))
			if (!message)
				return TRUE
			boutput(C, "<b>Your master's voice resonates in your head... </b> [message]")
			C.playsound_local(C.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)

		W.playsound_local(W.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
		boutput(W, "<b>You whisper to your summons:</b> [message]")
