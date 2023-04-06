/datum/abilityHolder/slasher
	usesPoints = FALSE
	regenRate = 0
	tabName = "Abilities"
	cast_while_dead = FALSE

ABSTRACT_TYPE(/datum/targetable/slasher)
/datum/targetable/slasher
	icon = 'icons/mob/slasher.dmi'
	icon_state = "template"
	preferred_holder_type = /datum/abilityHolder/slasher
