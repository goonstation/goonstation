/datum/targetable/grinch/grinch_cloak
	name = "Activate cloak (temp.)"
	desc = "Activates a cloaking ability for a limited amount of time."
	icon_state = "grinchcloak"
	cooldown = 6 MINUTES
	can_cast_while_cuffed = TRUE
	var/cloak_duration = 30 SECONDS

	cast(mob/target)
		var/mob/living/M = holder.owner

		if (M.bioHolder.HasEffect("chameleon"))
			boutput(M, SPAN_ALERT("You are already invisible."))
			return TRUE
		else
			var/datum/bioEffect/power/chameleon/cloak = M.bioHolder.AddEffect("chameleon", 0, src.cloak_duration / 10)
			if (cloak && istype(cloak))
				cloak.active = TRUE // Important!
				M.set_body_icon_dirty()
				boutput(M, SPAN_NOTICE("<b>Your chameleon cloak is available for the next [src.cloak_duration / 600] minutes.</b>"))
