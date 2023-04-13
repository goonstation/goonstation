/datum/abilityHolder/critter
	usesPoints = 0
	regenRate = 0
	tabName = "Abilities"
	topBarRendered = 1
	rendered = 1


// ----------------------------------------
// Generic abilities that critters may have
// ----------------------------------------

/datum/targetable/critter
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "template"
	preferred_holder_type = /datum/abilityHolder/critter

	proc/incapacitationCheck()
		var/mob/living/M = holder.owner
		return M.restrained() || is_incapacitated(M)

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
