/datum/targetable/vampire/radio_jammer
	name = "Radio interference"
	desc = "Temporarily disrupts all radio communication in the immediate vicinity."
	icon_state = "radiointer"
	targeted = 0
	cooldown = 1800
	pointCost = 50
	when_stunned = 0
	not_when_handcuffed = 0
	var/duration = 300
	unlock_message = "You have gained radio interference. It temporarily disables all headsets and intercoms close to you."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1

		if (!(radio_controller && istype(radio_controller)))
			boutput(M, __red("Couldn't find the global radio controller. Please report this to a coder."))
			return 1

		if (M in by_cat[TR_CAT_RADIO_JAMMERS])
			boutput(M, __red("You're already jamming radio signals."))
			return 1

		boutput(M, __blue("<b>You will disrupt radio signals in your immediate vicinity for the next [src.duration / 10] seconds.</b>"))
		OTHER_START_TRACKING_CAT(M, TR_CAT_RADIO_JAMMERS)
		SPAWN_DBG (src.duration)
			if (M && istype(M) && radio_controller && istype(radio_controller) && (M in by_cat[TR_CAT_RADIO_JAMMERS]))
				boutput(M, __red("<b>You no longer disrupt radio signals.</b>"))
				OTHER_STOP_TRACKING_CAT(M, TR_CAT_RADIO_JAMMERS)

		if (istype(H)) H.blood_tracking_output(src.pointCost)
		logTheThing("combat", M, null, "uses radio interference at [log_loc(M)].")
		return 0
