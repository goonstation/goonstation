TYPEINFO(/datum/component/acid_slime)
	initialization_args = list()

/datum/component/acid_slime

/datum/component/acid_slime/Initialize()
	if (!ismovable(src.parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(src.parent, COMSIG_MOVABLE_MOVED, .proc/slime)

/datum/component/acid_slime/proc/slime()
	var/turf/T = get_turf(src.parent)
	boutput(src.parent, T)
	if (!T || istype(T, /turf/simulated/shuttle) || istype(T, /turf/unsimulated) || istype(T, /turf/space)) return
	T.acidify_turf(12 SECONDS)

/datum/component/acid_slime/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
