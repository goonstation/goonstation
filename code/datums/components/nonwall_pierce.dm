/datum/component/nonwall_pierce

TYPEINFO(/datum/component/nonwall_pierce)
	initialization_args = list()

/datum/component/nonwall_pierce/Initialize()
	. = ..()
	if(!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE, PROC_REF(update_pierces))


/datum/component/nonwall_pierce/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	var/turf/T = get_turf(hit)
	if (isrestrictedz(T.z))
		return FALSE
	if (istype(hit, /obj/machinery/door) || iswall(hit))
		var/obj/machinery/door/door = hit
		return !door.density
	return PROJ_ATOM_PASSTHROUGH

/datum/component/nonwall_pierce/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE)
	. = ..()
