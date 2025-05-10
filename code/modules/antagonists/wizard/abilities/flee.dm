/datum/targetable/spell/flee
	name = "Flee"
	desc = "A teleport incantation that takes you to the wizard den. Has 3 uses."
	icon_state = "flee"
	cooldown = 60 SECONDS
	requires_robes = FALSE
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY
	maptext_colors = list("#39ffba", "#05bd82", "#038463", "#05bd82")
	voice_on_cast_start = FALSE
	var/uses = 3

	cast()
		if (!src.holder)
			return TRUE

		. = ..()
		if (src.holder.owner && ismob(src.holder.owner) && src.holder.owner.teleportscroll(TRUE, 3, tele_spell = src, jump_to_wizden = TRUE))
			src.uses--
			if (src.uses > 0)
				boutput(src.holder.owner, SPAN_ALERT("You now have [src.uses] [src.uses > 1 ? "uses" : "use"] left."))
			else
				boutput(src.holder.owner, SPAN_ALERT("This spell is now out of uses!"))
				var/datum/abilityHolder/abilHolder = src.holder
				abilHolder.removeAbility(src.type)
			return FALSE

		return TRUE
