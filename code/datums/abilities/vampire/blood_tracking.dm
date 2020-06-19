/datum/targetable/vampire/blood_tracking
	name = "Toggle blood tracking"
	desc = "Toggles blood gain/loss messages."
	icon_state = "bloodtrack"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	when_stunned = 2
	not_when_handcuffed = 0
	dont_lock_holder = 1
	ignore_holder_lock = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1

		if (ismobcritter(M) && !istype(H))
			boutput(M, __red("Critter mobs currently don't have to worry about blood. Lucky you."))
			return 1

		if (H.vamp_blood_tracking == 1)
			H.vamp_blood_tracking = 0
		else
			H.vamp_blood_tracking = 1

		boutput(M, __blue("Blood tracking turned [H.vamp_blood_tracking == 1 ? "on" : "off"]."))
		return 0
