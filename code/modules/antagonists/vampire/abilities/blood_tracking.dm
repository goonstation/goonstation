/datum/targetable/vampire/blood_tracking
	name = "Toggle blood tracking"
	desc = "Toggles blood gain/loss messages."
	icon_state = "bloodtrack"
	not_when_in_an_object = FALSE
	incapacitation_restriction = ABILITY_CAN_USE_ALWAYS
	can_cast_while_cuffed = TRUE
	lock_holder = FALSE
	ignore_holder_lock = TRUE

	cast(mob/target)
		var/mob/living/user = holder.owner
		var/datum/abilityHolder/vampire/AH = holder

		if (ismobcritter(user) && !istype(AH))
			boutput(user, "<span class='alert'>Critter mobs currently don't have to worry about blood. Lucky you.</span>")
			return TRUE

		if (AH.vamp_blood_tracking == TRUE)
			AH.vamp_blood_tracking = FALSE
		else
			AH.vamp_blood_tracking = TRUE

		boutput(user, "<span class='notice'>Blood tracking turned [AH.vamp_blood_tracking ? "on" : "off"].</span>")
		return FALSE
