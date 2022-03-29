/datum/component/battleroyale_death
	dupe_mode = COMPONENT_DUPE_UNIQUE

TYPEINFO(/datum/component/cell_holder)
	initialization_args = list()

/datum/component/battleroyale_death/Initialize()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/death_effect)

/datum/component/battleroyale_death/proc/death_effect()
	if (ishuman(parent))
		var/mob/living/carbon/human/H = parent
		H.unequip_all()
		H.elecgib()

/datum/component/battleroyale_death/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)
	. = ..()
