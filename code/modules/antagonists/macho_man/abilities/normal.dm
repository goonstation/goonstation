/datum/targetable/macho/macho_normal
	name = "Stance - Normal"
	desc = "We all know this stance is for boxing the hell out of dudes."
	icon_state = "golem"
	cast(atom/target)
		var/mob/living/M = holder.owner
		if (isalive(M) && !M.transforming)
			M.stance = "normal"
			M.visible_message("[M] assumes \a [M.stance] stance!", "You assume \a [M.stance] stance!")
