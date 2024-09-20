/datum/targetable/wraithAbility/speak
	name = "Spirit message"
	desc = "Telepathically speak to your minions."
	icon_state = "speak_summons"
	targeted = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0
	pointCost = 0
	do_logs = FALSE
	interrupt_action_bars = FALSE

	cast(mob/target)
		if (!holder)
			return 1
		. = ..()
		var/mob/living/intangible/wraith/W = holder.owner

		if (!W)
			return 1

		var/message = html_encode(input("What would you like to whisper to your minions?", "Whisper", "") as text)

		if (length(W.summons) == 0)
			boutput(W, "You have no minions to talk to.")
			return 1
		for(var/mob/living/critter/C in W.summons)
			logTheThing(LOG_SAY, W, "WRAITH WHISPER TO [constructTarget(C,"say")]: [message]")
			message = trimtext(copytext(sanitize(message), 1, 255))
			if (!message)
				return 1
			boutput(C, "<b>Your master's voice resonates in your head... </b> [message]")
			C.playsound_local(C.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)

		W.playsound_local(W.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
		boutput(usr, "<b>You whisper to your summons:</b> [message]")
		return 0
