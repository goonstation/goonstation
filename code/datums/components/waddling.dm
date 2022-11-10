/datum/component/waddling
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

TYPEINFO(/datum/component/waddling)
	initialization_args = list()

/datum/component/waddling/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/Waddle)

/datum/component/waddling/proc/Waddle()
	var/mob/living/L = parent
	if(isdead(L) || L.getStatusDuration("stunned") || L.lying)
		return
	var/matrix/M = matrix(L.transform)
	animate(L, pixel_z = 4, time = 0)
	animate(pixel_z = 0, transform = (turn(M, nextWaddle(L))), time=2)
	animate(pixel_z = 0, transform = M, time = 0)

/datum/component/waddling/proc/nextWaddle(var/mob/H)
	var/static/waddles = list()
	if (!waddles[H])
		waddles[H] = -16
	else
		waddles[H] = next_in_list(waddles[H], list(-16, 16))
	return waddles[H]

/datum/component/waddling/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	. = ..()
