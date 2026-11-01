ABSTRACT_TYPE(/datum/element/lifeprocess)
/datum/element/lifeprocess
	VAR_PROTECTED/target_type = /mob/living

/datum/element/lifeprocess/Attach(mob/living/target)
	if (!istype(target, target_type))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	src.RegisterSignal(target, COMSIG_LIVING_LIFEPROCESS_TICK, PROC_REF(process))
	. = ..()

/datum/element/lifeprocess/Detach(mob/living/target)
	src.UnregisterSignal(target, COMSIG_LIVING_LIFEPROCESS_TICK)
	. = ..()

/// Called once every life tick for each living mob.
/datum/element/lifeprocess/proc/process(mob/living/target, mult, datum/gas_mixture/environment)
	return
