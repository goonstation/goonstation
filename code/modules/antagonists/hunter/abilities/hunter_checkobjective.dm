/datum/targetable/hunter/hunter_trophycount
	name = "Check trophy value"
	desc = "Displays the combined value of all trophies in your possession."
	icon_state = "trophycount"
	targeted = FALSE
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	incapacitation_restriction = ABILITY_CAN_USE_ALWAYS
	can_cast_while_cuffed = TRUE
	hunter_only = 0
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		var/count = M.get_skull_value()

		if (count <= 0)
			boutput(M, SPAN_ALERT("<b>Combined trophy value: 0</b>"))
		else
			boutput(M, SPAN_NOTICE("<b>Combined trophy value: [count]</b>"))

		return 0
