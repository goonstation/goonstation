/datum/targetable/macho/macho_defense
	name = "Stance - Defensive"
	desc = "Take a defensive stance and counter any attackers"
	icon_state = "spellshield"
	cast(atom/target)
		. = ..()
		var/mob/living/M = holder.owner
		if (isalive(M) && !M.transforming)
			M.stance = "defensive"
			M.visible_message("[M] assumes \a [M.stance] stance!", "You assume \a [M.stance] stance!")
