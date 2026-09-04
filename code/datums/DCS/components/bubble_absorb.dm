///Componentized behaviour for sucking up bubbles into a gas mixture datum of some kind
///Necessary because atmos inheritance is a fuck
/datum/component/bubble_absorb
	var/datum/gas_mixture/tank = null
	VAR_PRIVATE/absorbing_bubble = FALSE

/datum/component/bubble_absorb/Initialize(datum/gas_mixture/tank)
	. = ..()
	src.tank = tank
	RegisterSignal(src.parent, COMSIG_MACHINERY_PROCESS, PROC_REF(look_for_bubble))

/datum/component/bubble_absorb/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_MACHINERY_PROCESS)
	src.tank = null
	. = ..()

/datum/component/bubble_absorb/proc/absorb_bubble(obj/bubble/bubble)
	if (src.absorbing_bubble)
		return
	var/atom/movable/parent = src.parent
	if (bubble.scale <= 0.2) //small bubble, devour without ceremony
		src.tank.merge(bubble.air_contents)
		qdel(bubble)
		return
	bubble.set_loc(parent)
	parent.vis_contents += bubble
	animate(bubble, 2 SECONDS, transform = matrix(bubble.transform, 0.1, 0.1, MATRIX_SCALE), easing = CUBIC_EASING)
	src.absorbing_bubble = TRUE
	SPAWN(2 SECONDS)
		src.absorbing_bubble = FALSE
		parent.vis_contents -= src
		src.tank.merge(bubble.air_contents)
		qdel(bubble)

/datum/component/bubble_absorb/proc/look_for_bubble(atom/movable/parent)
	if (src.absorbing_bubble)
		return
	var/obj/bubble/bubble = locate() in get_turf(parent)
	if (bubble)
		src.absorb_bubble(bubble)
		return
	for (var/dir in cardinal)
		var/turf/T = get_step(parent, dir)
		bubble = locate() in T
		if (bubble)
			src.absorb_bubble(bubble)
			return
