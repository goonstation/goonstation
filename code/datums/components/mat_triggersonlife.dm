/datum/component/holdertargeting/mat_triggersonlife
	dupe_mode = COMPONENT_DUPE_UNIQUE
	proctype = .proc/triggerMatOnLife
	signals = list(COMSIG_LIVING_LIFE_TICK)

/datum/component/holdertargeting/mat_triggersonlife/RegisterWithParent()
	..()
	RegisterSignal(parent, COMSIG_IMPLANT_IMPLANTED, .proc/on_pickup)
	RegisterSignal(parent, COMSIG_IMPLANT_REMOVED, .proc/on_dropped)


/datum/component/holdertargeting/mat_triggersonlife/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_IMPLANT_IMPLANTED)
	UnregisterSignal(parent, COMSIG_IMPLANT_REMOVED)
	..()

/datum/component/holdertargeting/mat_triggersonlife/proc/triggerMatOnLife(mob/M, mult)
	if(istype(parent, /atom/movable))
		var/atom/movable/AM = parent
		AM.material?.triggerOnLife(M, AM, mult)