/datum/targetable/macho/macho_offense
	name = "Stance - Offensive"
	desc = "Take an offensive stance and tackle people in your way"
	icon_state = "mutate"
	cast(atom/target)
		var/mob/living/M = holder.owner
		. = ..()
		if (isalive(M) && !M.transforming)
			M.stance = "offensive"
			M.visible_message("[holder.owner] assumes \a [M.stance] stance!", "You assume \a [M.stance] stance!")
