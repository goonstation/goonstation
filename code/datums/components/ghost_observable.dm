TYPEINFO(/datum/component/ghost_observable)
	initialization_args = list()

/// DO NOT USE THIS IF YOU'RE CODING SOMETHING. For use at runtime only. Use START_TRACKING_CAT.
/datum/component/ghost_observable

/datum/component/ghost_observable/Initialize()
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	OTHER_START_TRACKING_CAT(parent, TR_CAT_GHOST_OBSERVABLES)

/datum/component/bullet_holes/UnregisterFromParent()
	OTHER_STOP_TRACKING_CAT(parent, TR_CAT_GHOST_OBSERVABLES)
	. = ..()
