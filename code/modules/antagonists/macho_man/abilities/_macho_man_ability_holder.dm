/datum/abilityHolder/macho
	usesPoints = 0
	regenRate = 0
	tabName = "Abilities"
	cast_while_dead = 0
	var/display_buttons = 1

ABSTRACT_TYPE(/datum/targetable/macho)
/datum/targetable/macho
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "enthrall"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/macho
	interrupt_action_bars = FALSE
