/datum/component/proj_door_breach
/datum/component/proj_door_breach/Initialize()
	if (!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE, .proc/check_breach)

/datum/component/proj_door_breach/proc/check_breach(var/obj/projectile/P, var/atom/hit)
	var/turf/T = get_turf(hit)
	if (isrestrictedz(T.z))
		return 0
	if (istype(hit, /obj/machinery/door))
		P.special_data["door_hit"] = hit
		P.travelled = (P.max_range - 4) * 32
		//hit.ex_act(1)
		return PROJ_PASSOBJ

/datum/component/proj_door_breach/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE)
	. = ..()
