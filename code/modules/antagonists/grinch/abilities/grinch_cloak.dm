/datum/targetable/grinch/grinch_cloak
	name = "Activate cloak (temp.)"
	desc = "Activates a cloaking ability for a limited amount of time."
	targeted = 0
	target_anything = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 3600
	start_on_cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 0
	var/cloak_duration = 120

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		if (ismobcritter(M)) // Placeholder because only humans use bioeffects at the moment.
			if (M.invisibility != INVIS_NONE)
				boutput(M, __red("You are already invisible."))
				return 1

			APPLY_MOB_PROPERTY(M, PROP_INVISIBILITY, src, INVIS_CLOAK)
			M.UpdateOverlays(image('icons/mob/mob.dmi', "icon_state" = "shield"), "shield")
			boutput(M, __blue("<b>Your cloak will remain active for the next [src.cloak_duration / 60] minutes.</b>"))

			SPAWN_DBG (src.cloak_duration * 10)
				if (M && ismobcritter(M))
					REMOVE_MOB_PROPERTY(M, PROP_INVISIBILITY, src)
					M.UpdateOverlays(null, "shield")
					boutput(M, __red("<b>You are no longer invisible.</b>"))

		else if (ishuman(M))
			var/mob/living/carbon/human/MM = M
			if (!MM.bioHolder)
				boutput(MM, __red("You can't use this ability in your current form."))
				return 1

			if (MM.bioHolder.HasEffect("chameleon"))
				boutput(M, __red("You are already invisible."))
				return 1
			else
				var/datum/bioEffect/power/chameleon/CC = MM.bioHolder.AddEffect("chameleon", 0, src.cloak_duration)
				if (CC && istype(CC))
					CC.active = 1 // Important!
					MM.set_body_icon_dirty()
					boutput(M, __blue("<b>Your chameleon cloak is available for the next [src.cloak_duration / 60] minutes. Stand still to become invisible.</b>"))

		return 0
