/datum/component/proj_door_breach
	var/finished = FALSE

/datum/component/proj_door_breach/Initialize()
	if (!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE, .proc/check_breach)

/datum/component/proj_door_breach/proc/check_breach(var/obj/projectile/P, var/atom/hit)
	var/turf/T = get_turf(hit)
	if (finished || isrestrictedz(T.z))
		return 0
	if (istype(hit, /obj/machinery/door))
		var/obj/machinery/door/D = hit
		if(!D.cant_emag)
			P.special_data["door_hit"] = hit
			P.travelled = (P.max_range - 4) * 32
			//hit.ex_act(1)
			finished = TRUE
			return PROJ_PASSOBJ

/datum/component/proj_door_breach/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE)
	. = ..()
