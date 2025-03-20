/datum/component/gauntlet_critter

TYPEINFO(/datum/component/gauntlet_critter)
	initialization_args = list()

/datum/component/gauntlet_critter/Initialize()
	. = ..()
	if (!ismobcritter(parent) && !iscritter(parent))
		return COMPONENT_INCOMPATIBLE
	if (ismobcritter(parent))
		RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(gauntlet_death))
	if (iscritter(parent))
		RegisterSignal(parent, COMSIG_OBJ_CRITTER_DEATH, PROC_REF(gauntlet_death))
	global.gauntlet_controller.increaseCritters(parent)

/datum/component/gauntlet_critter/proc/gauntlet_death()
	global.gauntlet_controller.decreaseCritters(parent)

/datum/component/gauntlet_critter/UnregisterFromParent()
	if (ismobcritter(parent))
		UnregisterSignal(parent, COMSIG_MOB_DEATH)
	if (iscritter(parent))
		UnregisterSignal(parent, COMSIG_OBJ_CRITTER_DEATH)
	. = ..()
