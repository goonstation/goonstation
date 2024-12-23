/datum/targetable/vampire/radio_jammer
	name = "Radio interference"
	desc = "Temporarily disrupts all radio communication in the immediate vicinity."
	icon_state = "radiointer"
	targeted = 0
	cooldown = 1800
	pointCost = 50
	not_when_in_an_object = FALSE
	when_stunned = 0
	not_when_handcuffed = 0
	var/duration = 300
	unlock_message = "You have gained radio interference. It temporarily disables all headsets and intercoms close to you."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		if (!(radio_controller && istype(radio_controller)))
			boutput(M, SPAN_ALERT("Couldn't find the global radio controller. Please report this to a coder."))
			return 1

		if (M in by_cat[TR_CAT_RADIO_JAMMERS])
			boutput(M, SPAN_ALERT("You're already jamming radio signals."))
			return 1

		. = ..()
		boutput(M, SPAN_NOTICE("<b>You will disrupt radio signals in your immediate vicinity for the next [src.duration / 10] seconds.</b>"))
		OTHER_START_TRACKING_CAT(M, TR_CAT_RADIO_JAMMERS)
		SPAWN(src.duration)
			if (M && istype(M) && radio_controller && istype(radio_controller) && (M in by_cat[TR_CAT_RADIO_JAMMERS]))
				boutput(M, SPAN_ALERT("<b>You no longer disrupt radio signals.</b>"))
				OTHER_STOP_TRACKING_CAT(M, TR_CAT_RADIO_JAMMERS)

		logTheThing(LOG_COMBAT, M, "uses radio interference at [log_loc(M)].")
		return 0
