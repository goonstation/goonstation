/datum/component/loctargeting/mat_triggersonlife
	dupe_mode = COMPONENT_DUPE_UNIQUE
	proctype = .proc/triggerMatOnLife
	signals = list(COMSIG_LIVING_LIFE_TICK)
	loctype = /mob/living

/datum/component/loctargeting/mat_triggersonlife/proc/triggerMatOnLife(mob/M, mult)
	if(istype(parent, /atom/movable))
		var/atom/movable/AM = parent
		AM.material?.triggerOnLife(M, AM, mult)
