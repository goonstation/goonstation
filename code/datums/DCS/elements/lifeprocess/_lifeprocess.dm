/datum/element/lifeprocess/Attach(mob/living/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	src.RegisterSignal(target, COMSIG_LIVING_LIFEPROCESS_TICK, PROC_REF(_process))
	. = ..()

/datum/element/lifeprocess/Detach(mob/living/target)
	src.UnregisterSignal(target, COMSIG_LIVING_LIFEPROCESS_TICK)
	. = ..()

/// Called when the `COMSIG_LIVING_LIFEPROCESS_TICK` signal is received from a target. Used as a wrapper for `process`.
/datum/element/lifeprocess/proc/_process(mob/living/target, datum/gas_mixture/environment)
	SHOULD_NOT_OVERRIDE(TRUE)
	src.process(target, environment)
	//last_process = TIME

/// Called once every life tick for each living mob.
/datum/element/lifeprocess/proc/process(mob/living/target, datum/gas_mixture/environment)
	return
