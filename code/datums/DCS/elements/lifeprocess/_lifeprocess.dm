/datum/element/lifeprocess
	// This *slightly* breaks element purity, but it's better than these being components.
	VAR_PRIVATE/alist/last_process_by_target = alist()

/datum/element/lifeprocess/Attach(mob/living/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	src.last_process_by_target[target] = TIME
	src.RegisterSignal(target, COMSIG_LIVING_LIFEPROCESS_TICK, PROC_REF(_process))
	. = ..()

/datum/element/lifeprocess/Detach(mob/living/target)
	src.UnregisterSignal(target, COMSIG_LIVING_LIFEPROCESS_TICK)
	src.last_process_by_target -= target
	. = ..()

/// Called when the `COMSIG_LIVING_LIFEPROCESS_TICK` signal is received from a target. Used as a wrapper for `process`.
/datum/element/lifeprocess/proc/_process(mob/living/target, datum/gas_mixture/environment)
	SHOULD_NOT_OVERRIDE(TRUE)
	src.process(target, environment)
	src.last_process_by_target[target] = TIME

/// Returns the lag-compensation multiplier.
/datum/element/lifeprocess/proc/get_multiplier(mob/living/target)
	SHOULD_NOT_OVERRIDE(TRUE)
	return clamp(TIME - src.last_process_by_target[target], LIFE_PROCESS_TICK_SPACING, LIFE_PROCESS_CAP_TICK_SPACING) / LIFE_PROCESS_TICK_SPACING

/// Called once every life tick for each living mob.
/datum/element/lifeprocess/proc/process(mob/living/target, datum/gas_mixture/environment)
	return
