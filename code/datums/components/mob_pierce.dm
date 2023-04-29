/datum/component/gaseous_projectile

TYPEINFO(/datum/component/gaseous_projectile)
	initialization_args = list()

/datum/component/gaseous_projectile/Initialize()
	. = ..()
	if(!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE, .proc/update_pierces)

/datum/component/gaseous_projectile/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	var/turf/T = get_turf(hit)
	return PROJ_ATOM_PASSTHROUGH * !!T?.gas_cross(get_turf(P))

/datum/component/gaseous_projectile/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE)
	. = ..()
