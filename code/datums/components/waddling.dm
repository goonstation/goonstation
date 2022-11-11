/datum/component/waddling
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Height in pixels of waddling
	var/height
	/// Angle to swing while waddling
	var/angle

TYPEINFO(/datum/component/waddling)
	initialization_args = list(
		ARG_INFO("height", DATA_INPUT_NUM, "Height of the waddle", 4),
		ARG_INFO("angle", DATA_INPUT_NUM, "Angle of the waddle", 16),
	)

/datum/component/waddling/Initialize(height=4, angle=16)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.height = height
	src.angle = angle
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/Waddle)

/datum/component/waddling/proc/Waddle()
	var/mob/living/L = parent
	if(isdead(L) || L.getStatusDuration("stunned") || L.lying)
		return
	var/matrix/M = matrix(L.transform)
	animate(L, pixel_z = height, time = 0)
	animate(pixel_z = 0, transform = (turn(M, nextWaddle(L))), time=2)
	animate(pixel_z = 0, transform = M, time = 0)

/datum/component/waddling/proc/nextWaddle(var/mob/H)
	var/static/waddles = list()
	if (!waddles[H])
		waddles[H] = -angle
	else
		waddles[H] = next_in_list(waddles[H], list(-angle, angle))
	return waddles[H]

/datum/component/waddling/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	. = ..()
