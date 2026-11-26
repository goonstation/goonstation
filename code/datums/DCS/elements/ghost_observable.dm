/datum/element/ghost_observable/Attach(atom/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	OTHER_START_TRACKING_CAT(target, TR_CAT_GHOST_OBSERVABLES)
	. = ..()

/datum/element/ghost_observable/Detach(atom/target)
	OTHER_STOP_TRACKING_CAT(target, TR_CAT_GHOST_OBSERVABLES)
	. = ..()
