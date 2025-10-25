var/global/datum/vampire_ritual_manager/VampireRitualManager = new()

/datum/vampire_ritual_manager
	var/stop_ritual_incantation = "siste"
	var/list/incantation_first_lines = null
	var/list/active_rituals = null
	var/list/completed_rituals = null

/datum/vampire_ritual_manager/New()
	. = ..()

	src.active_rituals = list()
	src.completed_rituals = list()

	src.incantation_first_lines = list()
	for (var/T as anything in concrete_typesof(/datum/vampire_ritual))
		var/datum/vampire_ritual/ritual_dummy = new T()
		src.incantation_first_lines[ritual_dummy.incantation_lines[1]] = T

/datum/vampire_ritual_manager/proc/StartRitual(ritual_type, obj/decal/cleanable/vampire_ritual_circle/ritual_circle, mob/M)
	if (ritual_circle.current_ritual)
		return FALSE

	if (src.completed_rituals[ritual_type])
		return FALSE

	var/datum/vampire_ritual/ritual = new ritual_type(ritual_circle)
	if (!ritual.can_invoke_ritual())
		src.StopRitual(ritual)
		return FALSE

	ritual.increment_progress(M)
	src.active_rituals += ritual
	return TRUE

/datum/vampire_ritual_manager/proc/ProgressRitual(datum/vampire_ritual/ritual, mob/M)
	ritual.increment_progress(M)
	return TRUE

/datum/vampire_ritual_manager/proc/StopRitual(datum/vampire_ritual/ritual)
	src.active_rituals -= ritual
	ritual.unload_ritual()
	return TRUE

/datum/vampire_ritual_manager/proc/CompleteRitual(datum/vampire_ritual/ritual)
	src.active_rituals -= ritual

	if (!ritual.repeatable)
		src.completed_rituals[ritual.type] = TRUE

		// Remove the ritual's first line from the cache.
		for (var/line as anything in src.incantation_first_lines)
			if (!istype(ritual, src.incantation_first_lines[line]))
				continue

			src.incantation_first_lines -= line
			break

		// If someone is attempting to invoke this ritual elsewhere, cancel it.
		for (var/datum/ritual/active_ritual as anything in src.active_rituals)
			if (!istype(active_ritual, ritual.type))
				continue

			src.StopRitual(active_ritual)

	ritual.unload_ritual()
	return TRUE
